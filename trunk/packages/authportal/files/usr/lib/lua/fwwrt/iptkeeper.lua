#!/usr/bin/lua

-- Read dhcp.leases 
-- Compiling this info to the list of active IPs
-- and issuing all the necessary iptables commands
--
-- Daniel Podolsky, tpaba@cpan.org, 2009-07-23
-- Licence is the same as OpenWRT

module("fwwrt.iptkeeper", package.seeall)

require "fwwrt.util"
require "fwwrt.authportal"

-------------------------------------------------------------
-------------------------------------------------------------
-------------------------------------------------------------

local leasesFileName  = fwwrt.util.uciGet('dhcp.dnsmasq.leasefile', 'string')
local iptablesPath    = fwwrt.util.uciGet('fwwrt.firewall.iptables', 'string')

local loggedInTableChanged = false
local loggedIn             = {}
local leases               = {}

function getMac(ip)
	if (leases[ip]) then return leases[ip].mac end
	end

function logIpIn(ip, expire)
	if (leases[ip] == nil)
		then
		fwwrt.util.logger("LOG_ERR", "Address '"..tostring(ip).."' rejected: no lease found")
		return false
		end
	fwwrt.util.logger("LOG_NOTICE", "'"..tostring(ip).."' logged in with MAC '"..tostring(leases[ip].mac).."' till "..os.date("%Y%m%d-%H:%M:%S", expire))
	loggedIn[ip] = {["mac"] = leases[ip].mac, ["expire"] = expire + 0}
	loggedInTableChanged = true
	return true
	end

function logIpOut(ip)
	loggedIn[ip] = nil
	loggedInTableChanged = true
	fwwrt.authportal.doLogout(ip)
	fwwrt.util.logger("LOG_INFO", "'"..tostring(ip).."' logged out by request")
	return true
	end

function readLeases (leasesFileName, curTime)
	fwwrt.util.logger("LOG_DEBUG", "Updating dhcp info from '"..tostring(leasesFileName).."'")
	local leases = {}
	local file, error = io.open(leasesFileName, "r")
	if (file ~= nil)
		then
		local line = nil
		for line in file:lines()
			do
			local _, _, expire, mac, ip = string.find(line, "^(%d+)%s+(%S+)%s+(%S+)%s+%S+%s+%S+%s*$")
			expire=expire + 0
			if ((expire ~= nil) and (expire > curTime))
				then
				fwwrt.util.logger("LOG_DEBUG", "DHCP record '"..ip..", '"..mac.."', "..os.date("%Y%m%d-%H:%M:%S", expire))
				leases[ip] = {expire = expire, mac = mac}
				end
			end

		file:close()
	else
		fwwrt.util.logger("LOG_ALERT", "Can not open file '"..tostring(leasesFileName).."' for read: "..tostring(error))
		end
	return leases
	end

function loggedInCleanup (loggedIn, leases, curTime)
	local tmpTable = {}
	local ip, info
	for ip, info in pairs(loggedIn)
		do
		if (not (leases[ip] and leases[ip].expire > curTime))
			then
			fwwrt.authportal.doLogout(ip)
			loggedInTableChanged = true
			fwwrt.util.logger("LOG_INFO", "'"..tostring(ip).."' logged out as not renewed")
		elseif (info.mac ~= leases[ip].mac)
			then
			fwwrt.authportal.doLogout(ip)
			loggedInTableChanged = true
			fwwrt.util.logger("LOG_INFO", "'"..tostring(ip).."' logged out as MAC changed")
		elseif (info.expire < curTime)
			then
			fwwrt.authportal.doLogout(ip)
			loggedInTableChanged = true
			fwwrt.util.logger("LOG_INFO", "'"..tostring(ip).."' logged out as expired")
		else
			tmpTable[ip] = info
			end
		end
	return tmpTable
	end

function os_execute(command)
    local res = os.execute(command)
	fwwrt.util.logger(((res == 0) and "LOG_DEBUG" or "LOG_ALERT"), "Command '"..tostring(command).."' completed with code "..tostring(res))
	end

function iptCleanup()
	fwwrt.util.logger("LOG_DEBUG", "Cleaning access list")
	os_execute(iptablesPath.." -t nat --flush checkauth_PREROUTING")
	os_execute(iptablesPath.." -t nat --flush checkauth_POSTROUTING")
	os_execute(iptablesPath.."        --flush checkauth_FORWARD")
	end

iptCleanup()

local function iptAddRule(iptablesPath, tableName, chainName, conditions, destination)
    local rulePrefix = iptablesPath.." "..tableName.." -A "..chainName.."  "..conditions.." -j "
    if (fwwrt.util.loggerVerbose())
    	then
    	os_execute(rulePrefix.."LOG --log-level debug --log-prefix '"..chainName.."'")
    	end
	os_execute(rulePrefix..destination)
	end


function iptAllowIP(ip)
	fwwrt.util.logger("LOG_DEBUG", "Adding '"..tostring(ip).."' to access list")
	iptAddRule(iptablesPath, '-t nat', 'checkauth_PREROUTING',  '-s '..ip, 'authorized_PREROUTING')
	iptAddRule(iptablesPath, '-t nat', 'checkauth_POSTROUTING', '-s '..ip, 'authorized_POSTROUTING')
	iptAddRule(iptablesPath, '',       'checkauth_FORWARD',     '-s '..ip, 'authorized_FORWARD')
	end


function updateAccess()
	local curTime = os.time()

	leases   = readLeases(leasesFileName, curTime)
	loggedIn = loggedInCleanup(loggedIn, leases, curTime)

	if (loggedInTableChanged)
		then
		fwwrt.util.logger("LOG_NOTICE", "Updating access list")
		iptCleanup()
		for ip, info in pairs(loggedIn)
			do iptAllowIP(ip) end
		end

	loggedInTableChanged = false
	end

