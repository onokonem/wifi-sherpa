#!/usr/bin/lua

-- Read dhcp.leases 
-- Compiling this info to the list of active IPs
-- and issuing all the necessary iptables commands
--
-- Daniel Podolsky, tpaba@cpan.org, 2009-07-23
-- Licence is the same as OpenWRT

module("fwwrt.iptables", package.seeall)

require "fwwrt.util"
require "fwwrt.authportal"

-------------------------------------------------------------
-------------------------------------------------------------
-------------------------------------------------------------

local chains = {PREROUTING  = 'nat'
               ,POSTROUTING = 'nat'
               ,FORWARD     = 'filter'
               ,INPUT       = 'filter'
               }


local iptablesPath    = fwwrt.util.uciGet('fwwrt.firewall.iptables', 'string')


local listChainTemplate = iptablesPath.." -t %s -L %s -n"

-- Chain checkauth_FORWARD (1 references)
-- target     prot opt source               destination         
                            -- authorized_FORWARD  all  --  192.168.1.211        0.0.0.0/0
local parseChain        = "^%s*%S+%s+%S+%s+%S+%s+(%d+%.%d+%.%d+%.%d+)%s+%S+%s*$"

local rulePrefix = "%s -t %s -%s checkauth_%s -s %s -j %s 2>&1"
local workRule   = string.format(rulePrefix, iptablesPath, '%s', '%s', '%s', '%s', 'authorized_%s')
local logRule    = string.format(rulePrefix, iptablesPath, '%s', '%s', '%s', '%s', "LOG --log-level debug --log-prefix 'checkauth_%s '")


local function os_execute(cmd, logErr)
    logErr = logErr or 'LOG_ERR'
	local reader, err = io.popen(cmd, 'r')
	if (reader ~= nil) then
		local result = reader:read("*all")
		reader:close()
		if (string.len(result) > 0)
			then
			fwwrt.util.logger(logErr, "Unexpected output from command '"..cmd.."': "..result)
			end
	else
		fwwrt.util.logger(logErr, "Can not run '"..tostring(command).."': "..err)
		end
	end

local function addRule(tableName, chainName, ip)
    if (fwwrt.util.loggerVerbose())
    	then
    	os_execute(string.format(logRule, tableName, 'A', chainName, ip, chainName))
    	end
	os_execute(string.format(workRule, tableName, 'A', chainName, ip, chainName))
	end

local function delRule(tableName, chainName, ip)
	os_execute(string.format(logRule,  tableName, 'D', chainName, ip, chainName), 'LOG_DEBUG')
	os_execute(string.format(workRule, tableName, 'D', chainName, ip, chainName))
	end

local function listSrcIps(tableName, chainName)
	local ips = {}
	local reader, err = io.popen(string.format(listChainTemplate, tableName, chainName), 'r')
	if (reader ~= nil)
		then
		local line = nil
		for line in reader:lines()
			do
			local _, _, ip = string.find(line, parseChain)
			if (ip) then ips[ip] = true end
			end

		reader:close()
	else
		fwwrt.util.logger("LOG_CRIT", "Can not run '"..command.."': "..err)
		end
	return ips
	end

function syncChains(ipList)
    local tableName, chainName
    for chainName, tableName in pairs(chains) do
		curList = listSrcIps(tableName, 'checkauth_'..chainName)
		local ip, val
		for ip, val in pairs(curList) do
			if(not ipList[ip])
				then
				delRule(tableName, chainName, ip)
				end
			end
		for ip, val in pairs(ipList) do
			if(not curList[ip])
				then
				addRule(tableName, chainName, ip)
				end
			end
		end
	end
