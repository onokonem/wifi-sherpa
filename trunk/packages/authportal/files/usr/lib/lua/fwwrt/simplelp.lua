#!/usr/bin/lua

-- Simple lua (html?) pages engine
--
-- Daniel Podolsky, tpaba@cpan.org, 2009-08-04
-- Licence is the same as OpenWRT

-- [[
Syntax in Lua program:
slp = fwwrt.simplelp.loadFile(fileName[, env]) -- create simplelp from file
slp = fwwrt.simplelp.loadString(text[, env])   -- create simplelp from string
--
slp.run() - perform the page, return a result

Syntax inside of the file (text), load stage:
<%!fileName%>  -- tag replaced by content of named file, or by error message in case of problems
<%?fileName%>  -- tag replaced by content of named file, or by empty string in case of problems
<%:fieldName%> -- tag replaced by tostring(env.fieldName)

Syntax inside of the file (text), run stage:
<%luaExpression%> - perform the lua expression
<%=luaExpression%> - preform the lua expression and replace tag with result
]]

module("fwwrt.simplelp", package.seeall)

require "fwwrt.util"

local eol             = "\n"
local firstEolPattern = "^\r?\n"
local openTagPattern  = "<%%(%d*)"
local closeTagPattern = "%%>"

local function wrapStaticText(text, b, e)
    return "echo([["..(string.find(text, firstEolPattern, b) and eol or "")..string.sub(text, b, e).."]])"..eol or ""
end

local function wrapCode(text, b, e)
	if (string.sub(text, b, b) == "=") then
		return "echo("..string.sub(text, b+1, e)..")"..eol
	end

    return string.sub(text, b, e)
end

local function findCode(text, startSearch, level)
    local tagPosition, tagEnd, tagLevel = string.find(text, openTagPattern, startSearch)
    while tagPosition do
    	if (fwwrt.util.a2i(tagLevel) <= level) then return tagPosition, tagEnd end
    	startSearch = tagEnd + 1
    	tagPosition, tagEnd, tagLevel = string.find(text, openTagPattern, startSearch)
    	end
    return nil
	end


function evertText(text, level)
    level = level or 0

    local result = ""

    local startSearch = 1
    local tagPosition, tagEnd, tagLevel = findCode(text, startSearch, level)

    while (tagPosition) do
    	result = result..wrapStaticText(text, startSearch, tagPosition - 1)
    	
    	startSearch = tagEnd + 1
		tagPosition, tagEnd = string.find(text, closeTagPattern, startSearch)
		
		if (not tagPosition) then error("Close tag not found") end
		
		result = result..wrapCode(text, startSearch, tagPosition - 1)..eol
		
    	startSearch = tagEnd + 1
		tagPosition, tagEnd, tagLevel =  findCode(text, startSearch, level)
    end

    result = result..wrapStaticText(text, startSearch, -1)

    print(result)
    return result
end

function echo(container, ...)
	for i,a in ipairs(arg) do
		container.out = container.out..tostring(a)
		end
end

local loadstringPrefix = [[
return function(self, env)

self.out = ""

local function echo(...)     return fwwrt.simplelp.echo(self, ...)                end
local function inc(fileName) return fwwrt.simplelp.inc(fileName, self.level, env) end
local function req(fileName) return fwwrt.simplelp.req(fileName, self.level, env) end

]]

local loadstringPostfix = [[
 
end
]]

function loadString(str, level)
    level = level or 0
	local slp = {}
	slp.body  = assert(loadstring(loadstringPrefix..evertText(str, level)..loadstringPostfix))()
	slp.level = level

	slp.run = function(self, level, env)
		self:body(env)
		return out
		end
	
	slp.prepare = function(self, level, env)
	    level = level or 0x7fffffff
		self.body  = assert(loadstring(loadstringPrefix..evertText(self:run(level, env), level)..loadstringPostfix))()
		self.level = level
		end
	
	return slp
end

function loadFile(fileName, level)
	return loadString(fwwrt.util.fileToVariable(fileName), level)
	end

function doString(str, level, env)
	local slp = loadString(str, level)
	return slp:run(level, env)
end

function doFile(fileName, level, env)
	local slp = loadFile(fileName, level)
	return slp:run(level, env)
end

function req(fileName, level, env)
    local success, result = pcall(doFile, fileName, level, env)
	return success and result or "Can not include file '"..tostring(fileName).."': "..result
end

function inc(fileName, level, env)
    local success, result = pcall(doFile, fileName, level, env)
	return success and result or ""
end

