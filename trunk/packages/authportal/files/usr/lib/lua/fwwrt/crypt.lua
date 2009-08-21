#!/usr/bin/lua

-- FWWRT crypt module
--
-- Daniel Podolsky, tpaba@cpan.org, 2009-08-21
-- Roman Belyakovsky, roman.belyakovsky@gmail.com
-- Licence is the same as OpenWRT

module("fwwrt.crypt", package.seeall)

require "mime"
require "md5"

math.randomseed(os.time())

function randomString()
	return string.format("%8.8x", math.random(0,0x6fffffff))
end

local defaultKey = randomString()

function encrypt(message, key)
	key = key or defaultKey
	return  mime.b64(md5.crypt (message,key))
end

function decrypt(message, key)
	key = key or defaultKey
	local status,res = pcall(md5.decrypt,mime.unb64(message),key)
	return status and res or nil
end