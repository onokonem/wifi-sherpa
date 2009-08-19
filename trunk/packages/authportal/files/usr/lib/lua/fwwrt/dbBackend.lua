#!/usr/bin/lua

-- Database backend abstraction layer
-- Build on to of LuaSQL to provide db-independed methods
--
-- Daniel Podolsky, tpaba@cpan.org, 2009-08-16
-- Licence is the same as OpenWRT

module("fwwrt.dbBackend", package.seeall)

require "fwwrt.util"

local function wrap(parent, backend, wrapper)
    local w = {parent  = parent
              ,backend = backend
              }
    local mt = getmetatable(w) or {}
    mt.__index = wrapper
    setmetatable(w, mt)
	return w
	end

local sqlite2PreparedStatementMT = {}
--
local function replaceQM(statement, startSearch, replacement)
	local index = string.find(statement, "%?", startSearch)
	if (index == nil) then error("No more parameters expected") end
	return string.sub(statement, 1, index - 1)..replacement..string.sub(statement, index + 1, -1), (index + string.len(replacement))
	end
--
sqlite2PreparedStatementMT.unbind  = function(self, ...) self.binded = nil return true end
--
sqlite2PreparedStatementMT.bind    = function(self, ...)
    self.binded = string.gsub(self.backend, "[\n%s]+", " ")

    local startSearch = 1
	for i,v in ipairs(arg)
		do
		if((v[1] == "TEXT") or (v[1] == "BLOB")) then
			-- self.binded, startSearch = replaceQM(self.binded, startSearch, self.parent.parent:quotestr(tostring(v[2])))
			-- Not safe, but no quotestr is provided by LuaSQL driver
			self.binded, startSearch = replaceQM(self.binded, startSearch, "'"..tostring(v[2]).."'")
		elseif((v[1] == "FLOAT") or (v[1] == "INTEGER")) then
			self.binded, startSearch = replaceQM(self.binded, startSearch, tostring(tonumber(v[2])))
		elseif((v[1] == "BOOLEAN") or (v[1] == "BOOL")) then
			self.binded, startSearch = replaceQM(self.binded, startSearch, (v[2] and 'true' or 'false'))
		elseif(v[1] == "NULL") then
			self.binded, startSearch = replaceQM(self.binded, startSearch, "NULL")
		else
			error(string.format("Type '%s' is unknown", tostring(v[1])))
			end
		end
	return self
	end
--
sqlite2PreparedStatementMT.execute = function(self, ...)
	if (self.binded == nil) then error("Use bind first") end
	return self.parent:execute(self.binded)
	end

local sqlite2ConnMT = {}
sqlite2ConnMT.close          = function(self, ...) return self.backend:close(...)          end
sqlite2ConnMT.commit         = function(self, ...) return self.backend:commit(...)         end
sqlite2ConnMT.execute        = function(self, ...) return self.backend:execute(...)        end
sqlite2ConnMT.rollback       = function(self, ...) return self.backend:rollback(...)       end
sqlite2ConnMT.setautocommit  = function(self, ...) return self.backend:setautocommit(...)  end
sqlite2ConnMT.tables         = function(self, ...) return self.backend:tables(...)         end
sqlite2ConnMT.lastid         = function(self, ...) return self.backend:lastid(...)         end
sqlite2ConnMT.setbusytimeout = function(self, ...) return self.backend:setbusytimeout(...) end
sqlite2ConnMT.openblob       = function(self, ...) return self.backend:openblob(...)       end
sqlite2ConnMT.zeroblob       = function(self, ...) return self.backend:zeroblob(...)       end
sqlite2ConnMT.prepare        = function(self, statement)
    assert(statement, "Statement must be specified")
    return wrap(self, statement, sqlite2PreparedStatementMT)
	end

local sqlite2EnvMT = {}
sqlite2EnvMT.close    = function(self, ...) return self.backend:close(...)    end
sqlite2EnvMT.version  = function(self, ...) return self.backend.version(...)  end
sqlite2EnvMT.memory   = function(self, ...) return self.backend.memory(...)   end
sqlite2EnvMT.quotestr = function(self, ...) return self.backend.quotestr(...) end
sqlite2EnvMT.connect  = function(self, ...)
    return wrap(self, self.backend:connect(...), sqlite2ConnMT)
	end

local dbList = {}
--
dbList.sqlite2 = function()
	require "luasql.sqlite"
	return wrap(nil, luasql.sqlite(), sqlite2EnvMT)
	end
--
dbList.sqlite3 = function()
	require "luasql.sqlite3"
	return luasql.sqlite3()
	end

local function dbInit(dbType)
	if (not dbList[dbType])
		then
		error(string.format("DB type '%s' is not defined", tostring(dbType)))
		end
	return dbList[dbType]()
	end

local dbEnv = assert(dbInit(fwwrt.util.uciGet('fwwrt.authportal.dbType', 'string')))
local dbCon = assert(dbEnv:connect(fwwrt.util.uciGet('fwwrt.authportal.dbFile', 'string'), 'NOCREATE'))


function connect()
	return dbCon
	end


function bindAndExecute(statement, ...)
    assert(statement:bind(...))
    return assert(statement:execute())
	end
