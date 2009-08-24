#!/usr/bin/lua

-- Simple lua (html?) pages engine
--
-- Daniel Podolsky, tpaba@cpan.org, 2009-08-04
-- Licence is the same as OpenWRT

--[[
Syntax in Lua program:
slp = fwwrt.simplelp.loadFile(fileName[, env]) -- create simplelp from file
slp = fwwrt.simplelp.loadString(text[, env])   -- create simplelp from string
--
slp:run([env]) - perform the page, return a result

Syntax inside of the file (text), load stage:
<%!fileName%>  -- tag replaced by content of named file, or by error message in case of problems
<%?fileName%>  -- tag replaced by content of named file, or by empty string in case of problems
<%:fieldName%> -- tag replaced by tostring(env.fieldName)

Syntax inside of the file (text), run stage:
<%luaExpression%>  -- perform the lua expression
<%=luaExpression%> -- preform the lua expression and replace tag with result

Syntax inside of the run-stage tags:
env.fieldName -- a field from env table passed to run() method
echo(...)     -- all the arguments are tistring()-ed added to the result
req(fileName) -- content of named file, or error message in case of problems added to the result
inc(fileName) -- content of named file, or empty string in case of problems added to the result
]]

module("fwwrt.simplelp", package.seeall)

require "fwwrt.util"

local eol             = "\n"
local firstEolPattern = "^\r?\n"
local openTagPattern  = "<%%"
local closeTagPattern = "%%>"

local includePatterns = {}
includePatterns["<%%%!%s*([^%s%%>]+)%s*<%%>"] = function(param)
    local success, result = pcall(fileToVariable, param)
	return success and result or "Can not include file '"..tostring(fileName).."': "..result
	end
includePatterns["<%%%?%s*([^%s<%%>]+)%s*%%>"] = function(param)
    local success, result = pcall(fileToVariable, param)
	return success and result or ""
	end
includePatterns["<%%%:%s*([^%s<%%>]+)%s*%%>"] = function(param, env)
    local success, result = pcall(fileToVariable, param)
	return tostring(env[param])
	end

local maxSubst = 100

local function recursionError()
	return string.format("!!! Error: substitution was not completed in %d turns, endless recursion suspected !!!", maxSubst)
	end

local function substByFunc(text, pattern, substFunc)
	local found  = false
	local result = ""

	local startSearch = 1
	local tagPosition, tagEnd, tagParam = string.find(text, pattern, startSearch)
	while (tagPosition) do
	    found  = true
		result = result..string.sub(text, startSearch, tagPosition - 1)..substFunc(tagParam, env)
	    startSearch = tagEnd + 1
	    tagPosition, tagEnd, tagParam = string.find(text, includePattern, startSearch)
		end
	result = result..string.sub(text, startSearch, -1)
	return found, result
	end

local function assemble(text, env)
    local noSubst   = true
    local substTurn = 0
    print("text  in: '"..text.."'")
    repeat
        noSubst   = true
	    local pattern, func
	    for pattern, substFunc in pairs(includePatterns) do
	        local found
	        found, text = substByFunc(text, pattern, (substTurn < maxSubst) and substFunc or recursionError)
	        noSubst = noSubst and (not found)
	    	end
	    
	    substTurn = substTurn + 1
		until (noSubst and (substTurn > maxSubst))

    print("text out: '"..text.."'")
    return text
	end

local function wrapStaticText(text, b, e)
    return "echo([["..(string.find(text, firstEolPattern, b) and eol or "")..string.sub(text, b, e).."]])"..eol or ""
end

local function wrapCode(text, b, e)
	if (string.sub(text, b, b) == "=") then
		return "echo("..string.sub(text, b+1, e)..")"..eol
	end

    return string.sub(text, b, e)
end

local emptyEnv = {}

function evertText(text, env)
    env  = env or emptyEnv
    text = assemble(text, env)

    local result = ""

    local startSearch = 1
    local tagPosition, tagEnd = string.find(text, openTagPattern, startSearch)

    while (tagPosition) do
    	result = result..wrapStaticText(text, startSearch, tagPosition - 1)
    	
    	startSearch = tagEnd + 1
		tagPosition, tagEnd = string.find(text, closeTagPattern, startSearch)
		
		if (not tagPosition) then
			result = result.."!!! Error: code block opened but not closed !!!"
			startSearch = -1
			break
			end
		
		result = result..wrapCode(text, startSearch, tagPosition - 1)..eol
		
    	startSearch = tagEnd + 1
		tagPosition, tagEnd = string.find(text, openTagPattern, startSearch)
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

local function echo(...)     return fwwrt.simplelp.echo(self, ...)    end
local function inc(fileName) return fwwrt.simplelp.inc(fileName, env) end
local function req(fileName) return fwwrt.simplelp.req(fileName, env) end

]]

local loadstringPostfix = [[
 
end
]]

function loadString(str, env)
    level = level or 0
	local slp = {}
	slp.body  = assert(loadstring(loadstringPrefix..evertText(str, env)..loadstringPostfix))()

	slp.run = function(self, env)
		self:body(env)
		return self.out
		end
	
	slp.prepare = function(self, env)
		self.body  = assert(loadstring(loadstringPrefix..evertText(self:run(env))..loadstringPostfix))()
		self.level = level
		end
	
	return slp
end

function loadFile(fileName, env)
	return loadString(fwwrt.util.fileToVariable(fileName), env)
	end

function doString(str, env)
	local slp = loadString(str, env)
	return slp:run(env)
end

function doFile(fileName, env)
	local slp = loadFile(fileName, env)
	return slp:run(env)
end

function req(fileName, env)
    local success, result = pcall(doFile, fileName, env)
	return success and result or "Can not include file '"..tostring(fileName).."': "..result
end

function inc(fileName, env)
    local success, result = pcall(doFile, fileName, env)
	return success and result or ""
end

