#!/usr/bin/lua

-- Simple lua (html?) pages engine
--
-- Daniel Podolsky, tpaba@cpan.org, 2009-08-04
-- Licence is the same as OpenWRT


module("fwwrt.simplelp", package.seeall)

require "fwwrt.util"

local eol = "\n"
local openTagPattern  = "<%%"
local closeTagPattern = "%%>"


local function wrapStaticText(text, b, e)
    return (b <= e) and "echo([["..eol..string.sub(text, b, e).."]])"..eol or ""
	end

local function wrapCode(text, b, e)
	if (b > e) then return "" end

	if (string.sub(text, b, b) == "=") then
		return "echo("..string.sub(text, b+1, e)..")"
		end

    return string.sub(text, b, e)
	end

function evertText(text)
    local result = ""

    local startSearch = 1
    local tagPosition = string.find(text, openTagPattern, startSearch)

    while (tagPosition) do
    	result = result..wrapStaticText(text, startSearch, tagPosition - 1)

    	startSearch = tagPosition + 2
		tagPosition       = string.find(text, closeTagPattern, startSearch)

		if (not tagPosition) then error("Close tag not found") end

		result = result..wrapCode(text, startSearch, tagPosition - 1)..eol
		
    	startSearch = tagPosition + 2
		tagPosition = string.find(text, openTagPattern, startSearch)
    	end

    result = result..wrapStaticText(text, startSearch, -1)

    print("result: '"..result.."'")
    return result
	end


function echo(out, ...)
	for i,a in ipairs(arg) do
		out = out..tostring(a)
		end
	end

local loadstringPrefix = [[
return function(container)

local function echo(...)     return fwwrt.simplelp.echo(container.out, ...) end
local function inc(fileName) return fwwrt.simplelp.inc(fileName)            end
local function req(fileName) return fwwrt.simplelp.req(fileName)            end

]]

local loadstringPostfix = [[
end
]]

(assert(loadstring(loadstringPrefix..evertText(aaa)..loadstringPostfix))())(h)

function doString(str)
	local container = {out = ""}
	(assert(loadstring(loadstringPrefix..evertText(str)..loadstringPostfix))())(container)
	return container.out
	end

function req(fileName)
    return doString(fwwrt.util.fileToVariable(fileName))
	end

function inc(fileName)
	return pcall(req(fileName))
	end

