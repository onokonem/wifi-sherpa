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

function getMac(ipaddr)
	return leases[ipaddr] and leases[ipaddr].macaddr
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
			local _, _, expire, macaddr, ipaddr = string.find(line, "^(%d+)%s+(%S+)%s+(%S+)%s+%S+%s+%S+%s*$")
			expire=expire + 0
			if ((expire ~= nil) and (expire > curTime))
				then
				fwwrt.util.logger("LOG_DEBUG", "DHCP record '"..ipaddr..", '"..macaddr.."', "..os.date("%Y%m%d-%H:%M:%S", expire))
				leases[ipaddr] = {expire = expire, macaddr = macaddr}
				end
			end

		reader:close()
	else
		fwwrt.util.logger("LOG_ALERT", "Can not open file '"..tostring(leasesFileName).."' for read: "..tostring(error))
		end
	return leases
	end

function updateAccess()
	local curTime = os.time()

	leases   = readLeases(leasesFileName, curTime)

	local ipaddr, info
	for ipaddr, info in pairs(fwwrt.authportal.getActiveUsers())
		do
		if (not (leases[ipaddr] and leases[ipaddr].expire > curTime))
			then
			fwwrt.authportal.doLogout(ipaddr, "not renewed")
		elseif (info.macaddr ~= leases[ipaddr].macaddr)
			then
			fwwrt.authportal.doLogout(ipaddr, "MAC changed from "..tostring(info.macaddr).." to "..leases[ipaddr].macaddr)
		elseif (tonumber(info.expire) < curTime)
			then
			fwwrt.authportal.doLogout(ipaddr, "expired")
			end
		end

	fwwrt.iptables.syncChains(fwwrt.authportal.getActiveUsers())
	end

