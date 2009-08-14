#!/usr/bin/lua

-- FWWRT helper methods
--
-- Daniel Podolsky, tpaba@cpan.org, 2009-08-04
-- Licence is the same as OpenWRT


module("fwwrt.util", package.seeall)

------------------------------------------------------------------------------
-- Logger methods ------------------------------------------------------------
------------------------------------------------------------------------------

local _verbose = true

function loggerVerbose(verbose)
	if (verbose ~= nil) then _verbose = verbose end
	return _verbose
	end

local internalLogger = function(lvl, msg)
	io.stderr:write(os.date("%Y%m%d-%H:%M:%S", expire).." "..tostring(lvl).." "..tostring(msg).."\n")
	io.stderr:flush()
	end

function initLogger(tag, facility, verbose, stderr)
	tag      = tag      and tag      or debug.getinfo(3, "S").short_src
	facility = facility and facility or "LOG_USER"
	_verbose = (verbose == nil) or verbose
	stderr   = (stderr  == nil) or stderr
	if (syslog)
		then
		local i = debug.getinfo(2)
		logger("LOG_WARNING", i.short_src..":"..i.currentline..": logger initialized already")
	elseif(pcall(require, "syslog"))
		then
		syslog.openlog(tag
		              ,syslog.LOG_ODELAY + syslog.LOG_PID + (stderr and syslog.LOG_PERROR or 0)
		              ,facility
		              )
		internalLogger = syslog.syslog
		end
	end

function logger(lvl, msg)
	if (_verbose or (lvl ~= "LOG_DEBUG")) then internalLogger(lvl, msg) end
	end

------------------------------------------------------------------------------
-- Tables methods ------------------------------------------------------------
------------------------------------------------------------------------------

function printTable(table, pref, shift, maxLevel, level, loopDetect) -- loopDetect, level - leave empty
    shift      = shift      or ""
    maxLevel   = maxLevel   or 3
    loopDetect = loopDetect or {}
    level      = level      or 0

    if type(table) ~= "table" then
            error("not a table, check your hands")
    end

	loopDetect[table] = true
	
    local res = ""
    local i1 = 0
    local key, val

    for key, val in pairs(table) do
		res=res..pref.."["..((type(key) == 'string') and "'"..key.."'" or tostring(key)).."] = '"..tostring(val).."'\n"
		if type(val) == "table" and level <= maxLevel then
			if not loopDetect[val] then
				res=res..printTable(val, tostring(pref).."["..tostring(key).."]", shift, maxLevel, level + 1, loopDetect)
			else
				res=res.."duplicate, id = '"..tostring(val).."' on level '"..level.."'\n"
				end
			end
		end
	-- loopDetect[table] = nil
	return res
	end


------------------------------------------------------------------------------
-- UCI methods ---------------------------------------------------------------
------------------------------------------------------------------------------

require "uci"

local function findSubsection(section, subsectionName)
	if (not section) then return nil end

	if (section[subsectionName]) then return section[subsectionName] end

	local key, val
	for key, val in pairs(section)
		do
		if (val['.type'] and (val['.type'] == subsectionName))
			then return val end
		end

	return nil
	end

function toboolean(param)
    if (param == nil) then return false end
    param = assert(string.lower(tostring(param)), "'"..tostring(param).."' is not boolean")
    if ((param == 'yes') or (param == 'true')  or (param == 'on')  or (param == '1')) then return true  end
    if ((param == 'no')  or (param == 'false') or (param == 'off') or (param == '0')) then return false end
    error("'"..param.."' is not boolean")
	end

local converters = {['string']  = tostring
                   ,['number']  = function(param) return assert(tonumber(param), "'"..tostring(param).."' is not number") end 
                   ,['boolean'] = toboolean
                   }

function uciGet(paramName, paramType)
    local converter  = converters[paramType]
    assert(converter, "'"..tostring(paramType).."' is not a valid type")

	local err = "Parameter  '"..paramName.."' not found"
	
    local _, _, sectionName, subsectionName, optionName = string.find(paramName, "^([^%.]+)%.([^%.]+)%.([^%.]+)$")
    assert(optionName, err)

	local subsection = findSubsection(uci.get_all(sectionName), subsectionName)
	assert((subsection and (subsection[optionName] ~= nil)), err)
	
	return converter(subsection[optionName])
	end

------------------------------------------------------------------------------
-- I/O methods ---------------------------------------------------------------
------------------------------------------------------------------------------

function fileToVariable(fileName)
	local content = ""
	local file = assert(io.open(fileName, "r"), "Could not open file '"..fileName.."' for read")
	content=file:read("*a")
	file:close()
	return content
end

------------------------------------------------------------------------------
-- Time methods --------------------------------------------------------------
------------------------------------------------------------------------------

function yeldSleep(t, yieldParam)
	local curTime = os.time()
	while ((os.time() - curTime) < t) do coroutine.yield(yieldParam) end
	end

