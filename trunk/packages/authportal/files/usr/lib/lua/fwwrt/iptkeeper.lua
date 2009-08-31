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
require "fwwrt.iptables"

-------------------------------------------------------------
-------------------------------------------------------------
-------------------------------------------------------------

local leasesFileName  = fwwrt.util.uciGet('dhcp.dnsmasq.leasefile', 'string')

local leases               = {}

function getMac(ip)
	return leases[ip] and leases[ip].mac
	end

function readLeases (leasesFileName, curTime)
	fwwrt.util.logger("LOG_DEBUG", "Updating dhcp info from '"..tostring(leasesFileName).."'")
	local leases = {}
	local reader, error = io.open(leasesFileName, "r")
	if (reader ~= nil)
		then
		local line = nil
		for line in reader:lines()
			do
			local _, _, expire, mac, ip = string.find(line, "^(%d+)%s+(%S+)%s+(%S+)%s+%S+%s+%S+%s*$")
			expire=expire + 0
			if ((expire ~= nil) and (expire > curTime))
				then
				fwwrt.util.logger("LOG_DEBUG", "DHCP record '"..ip..", '"..mac.."', "..os.date("%Y%m%d-%H:%M:%S", expire))
				leases[ip] = {expire = expire, mac = mac}
				end
			end

		reader:close()
	else
		fwwrt.util.logger("LOG_ALERT", "Can not open file '"..tostring(leasesFileName).."' for read: "..tostring(error))
		end
	return leases
	end

function loggedInCleanup (loggedIn, leases, curTime)
    local loggedIn = fwwrt.authportal.getActiveUsers()
	local ip, info
	for ip, info in pairs(loggedIn)
		do
		if (not (leases[ip] and leases[ip].expire > curTime))
			then
			fwwrt.authportal.doLogout(ip, "not renewed")
		elseif (info.mac ~= leases[ip].mac)
			then
			fwwrt.authportal.doLogout(ip, "MAC changed")
		elseif (info.expire < curTime)
			then
			fwwrt.authportal.doLogout(ip, "expired")
			end
		end
	end


function updateAccess()
	local curTime = os.time()

	leases   = readLeases(leasesFileName, curTime)

	local ip, info
	for ip, info in pairs(fwwrt.authportal.getActiveUsers())
		do
		if (not (leases[ip] and leases[ip].expire > curTime))
			then
			fwwrt.authportal.doLogout(ip, "not renewed")
		elseif (info.mac ~= leases[ip].mac)
			then
			fwwrt.authportal.doLogout(ip, "MAC changed")
		elseif (info.expire < curTime)
			then
			fwwrt.authportal.doLogout(ip, "expired")
			end
		end

	fwwrt.iptables.syncChains(fwwrt.authportal.getActiveUsers())
	end

