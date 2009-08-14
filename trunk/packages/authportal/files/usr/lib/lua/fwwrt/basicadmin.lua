#!/usr/bin/lua

-- FWWRT authentication portal helper methods
--
-- Daniel Podolsky, tpaba@cpan.org, 2009-08-04
-- Licence is the same as OpenWRT

module("fwwrt.basicadmin", package.seeall)

require "luasql.sqlite"

require "fwwrt.authportal"

local webDir     = fwwrt.util.uciGet('httpd.httpd.home',            'string')
local hostname   = fwwrt.util.uciGet('fwwrt.authportal.httpsName',  'string')
--local ssid       = fwwrt.util.uciGet('wireless.wifi-iface.ssid',  'string')

function insertUser(user) --should sheck values and return errors correctly
--	assert (fwwrt.authportal.dbCon:execute(string.format([[
--		INSERT INTO users(username)
--		VALUES ("$s")]], user))
--	)
	assert (fwwrt.authportal.dbCon:execute([[
		INSERT INTO users(username)
		VALUES ("]]..user.."\")")
	)
end

function autoMakeUser(passLength, rSeed)
	abiturient = generate(passLength, rSeed)
	tries = 1
	while pcall(insertUser,abiturient) ~= true and tries < 50 do
		tries = tries + 1
	end
	print("user added in "..tries.." tries ==================================================")
	return abiturient
end



function generate(length, rSeed, charSet)
	math.randomseed(rSeed)
	local Chars = {}
	for Loop = 0, 255 do
	   Chars[Loop+1] = string.char(Loop)
	end
	local String = table.concat(Chars)

	local Built = {['.'] = Chars}

	local AddLookup = function(CharSet)
	   local Substitute = string.gsub(String, '[^'..CharSet..']', '')
	   local Lookup = {}
	   for Loop = 1, string.len(Substitute) do
	       Lookup[Loop] = string.sub(Substitute, Loop, Loop)
	   end
	   Built[CharSet] = Lookup

	   return Lookup
	end

	 local function randGen(Length, CharSet)
	   -- Length (number)
	   -- CharSet (string, optional); e.g. %l%d for lower case letters and digits

	   local CharSet = CharSet or '.'

	   if CharSet == '' then
	      return ''
	   else
	      local Result = {}
	      local Lookup = Built[CharSet] or AddLookup(CharSet)
	      local Range = table.getn(Lookup)

	      for Loop = 1,Length do
	         Result[Loop] = Lookup[math.random(1, Range)]
	      end

	      return table.concat(Result)
	   end
	end

	if charSet == nil then
		charSet = "%l%d"
	end

	return randGen(length,charSet)
end

function doAdmin(wsapi_env, request) --generate cards, create users
	local width="40%"
	local height="85mm"
--	local pt=5 --cards per page
--	local row=pt*number
--	local col=2
--	local request = wsapi.request.new(wsapi_env)
--	coroutine.yield("<pre>"..printTable(request, "request", ".", 10).."</pre>")
	local countP = request.POST.count
--	local note = request.POST.note
	
	
	local useIn = {}
	useIn.day = 24*60*60
	useIn.week, useIn.month, useIn.year =
	useIn.day*7,useIn.day*31-12*60*60,useIn.day*365
--	local useBy = os.time() + useIn[request.POST.useIn]
	
-- 	local expireIn = request.POST.eMinute*60 + 
-- 	request.POST.eHour*60*60 + request.POST.eDay*60*60*24 + 
-- 	request.POST.eMonth*60*60*24*30+60*60*12 + request.POST.eYear*60*60*24*365
	
	local passLength = 8
	function multiplyStrings (text, count)
		local ntext = ""
		for i = 1, count do
		 	ntext = ntext..text
		end
		return ntext
	end
	s = 234
	template=("$do_cosm[["..fwwrt.util.fileToVariable(webDir.."/cards.template").."]]")
	values = {
		do_cosm = function()
			cosmo.yield{			
				tables = multiplyStrings("$do_cosm[["..
					fwwrt.util.fileToVariable(webDir.."/cardTable.template").."]]", countP),
				rows = "$do_cosm[["..fwwrt.util.fileToVariable(webDir.."/cardRows.template").."]]",
				card = "$do_user[["..fwwrt.util.fileToVariable(webDir.."/card.template").."]]",
--				ssid = ssid,
				height = height,
				width = width
--				expireIn = expireIn
			}
		end,
		do_user = function()
			s = s + 5
			cosmo.yield{
				user = autoMakeUser(passLength, s*3+os.time()),
				ssid = fwwrt.util.uciGet('wireless.wifi-iface.ssid',  'string'),
--				note = "i = '"..s.."'",
				height = height,
				width = width
			}
		end
	}
	
	i = 0
	while string.find(template, "%$") ~= nill and i < 10 do
		template = cosmo.fill(template,values)
		print("filling template... Level "..i)
		i = i + 1
	end
	print("ok, page ready to show")
--	print(template)
--	print("ssid = "..ssid)
	coroutine.yield(template)
--	test(wsapi_env)
	print("3003")
end

function showBasicAdminForm(wsapi_env) --showlogin
	local template  = fwwrt.util.fileToVariable(webDir.."/cardGen.template")
	local values = {actionUrl = "https://"..hostname.."/admin"
	               }

	local process = function () coroutine.yield(cosmo.fill(template, values)) end
	return 200, commonHeaders, coroutine.wrap(process)
end

function processBasicAdminForm(wsapi_env) --showlogin
	local request  = wsapi.request.new(wsapi_env)

    if (request.method ~= 'POST')
    	then return showBasicAdminForm(wsapi_env) end

    local callDoAdmin = function() return doAdmin(wsapi_env, request) end
    return 200, commonHeaders, coroutine.wrap(callDoAdmin)
end
