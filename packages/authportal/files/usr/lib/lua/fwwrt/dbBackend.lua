#!/usr/bin/lua

-- Database backend abstraction layer
-- Build on to of LuaSQL to provide db-independed methods
--
-- Daniel Podolsky, tpaba@cpan.org, 2009-08-16
-- Licence is the same as OpenWRT

module("fwwrt.dbBackend", package.seeall)

require "fwwrt.util"

local dbEnv = nil
local dbCon = nil

function connection()
	return dbCon
	end

prepare = function (statement)
	return dbCon:prepare(statement)
	end
	
execute = function (statement)
	return dbCon:execute(statement)
	end
	
local dbList = {["sqlite2"] = function()
                	require "luasql.sqlite"
                	return luasql.sqlite()
                	end
               ,["sqlite3"] = function()
                	require "luasql.sqlite3"
                	return luasql.sqlite3()
                	end
               }

local function dbInit(dbType)
	if (not dbList[dbType])
		then
		error(string.format("DB type '%s' is not defined", tostring(dbType)))
		end
	return dbList[dbType]()
	end

dbEnv = assert(dbInit(fwwrt.util.uciGet('fwwrt.authportal.dbType', 'string')))
dbCon = assert(dbEnv:connect(fwwrt.util.uciGet('fwwrt.authportal.dbFile', 'string'), 'NOCREATE'))


