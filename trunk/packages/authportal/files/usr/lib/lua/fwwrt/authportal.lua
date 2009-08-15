#!/usr/bin/lua

-- FWWRT authentication portal helper methods
--
-- Daniel Podolsky, tpaba@cpan.org, 2009-08-04
-- Roman Belyakovsky, roman.belyakovsky@gmail.com
-- Licence is the same as OpenWRT


module("fwwrt.authportal", package.seeall)

require "wsapi.util"
require "wsapi.request"
require "cosmo"
require "luasql.sqlite"

require "fwwrt.util"
require "fwwrt.iptkeeper"

local webDir     = fwwrt.util.uciGet('httpd.httpd.home',            'string')
local hostname   = fwwrt.util.uciGet('fwwrt.authportal.httpsName',  'string')
local loginDelay = fwwrt.util.uciGet('fwwrt.authportal.logindelay', 'number')
local dbFile     = fwwrt.util.uciGet('fwwrt.authportal.dbFile',     'string')
--local ssid       = fwwrt.util.uciGet('wireless.wifi-iface.ssid',  'string')

-- create environment object
dbEnv = assert(luasql.sqlite())
-- connect to data source
dbCon = assert(dbEnv:connect(dbFile, 'NOCREATE'))
	
commonHeaders   = {["Content-type"] = "text/html; charset=utf-8"
                        }
function redirectHeaders(path)
	return {["Content-type"] = "text/html; charset=utf-8"
	       ,["Location"]     = path
	       }
	end

local redirectBody = "<htmp><head><title>302 Redirect</title></head><body>302 Redirect</body></html>"

function yeldSleep()
	fwwrt.util.yeldSleep(loginDelay, "")
	coroutine.yield(redirectBody)
	end


function showLogoutForm(wsapi_env) --showlogin
	local template  = fwwrt.util.fileToVariable(webDir.."/showLogout.template")
	local values = {actionUrl = "http://"..hostname.."/logout"
	               ,origUrl   = "http://"..hostname.."/"
	               }

	local process = function () coroutine.yield(cosmo.fill(template, values)) end
	return 200, commonHeaders, coroutine.wrap(process)
end

function processLogoutForm(wsapi_env) --showlogin
	local request  = wsapi.request.new(wsapi_env)

    if (not (request.POST and request.POST.logout))
    	then return showLogoutForm(wsapi_env) end

    fwwrt.iptkeeper.logIpOut(wsapi_env.REMOTE_ADDR)
	return 302, redirectHeaders("http://"..hostname.."/"), coroutine.wrap(yeldSleep)
end

function doLogout(ip)
--	if ip ~= nil
--		select from activeusers and operate values for all of them
--		dbCon:exec[[delete from activeusers]]
--	else
--			local stmt = dbCon:prepare[[ SELECT * FROM operators WHERE username = :user AND pass = :pass ]]

			return true

end

-- do function doLogin()

function showLoginForm(wsapi_env, reason, message) --showlogin
    reason = reason or ""
	local loginText = ""
	local wrong     = ""
	local pass      = fwwrt.util.fileToVariable(webDir.."/loginNoPass.template")
	local template  = fwwrt.util.fileToVariable(webDir.."/showLogin.template")
	local values    = {actionUrl = "https://"..hostname.."/"
	                  ,origUrl   = "http://"..wsapi_env.SERVER_NAME..wsapi_env.PATH_INFO
	                  ,loginText = loginText
	                  ,pass      = pass
	                  ,wrong     = wrong
	                  ,reason    = reason
	                  }

	local process = function () coroutine.yield(cosmo.fill(template, values)) end
	return 200, commonHeaders, coroutine.wrap(process)
end

function checkLogin(user)
	local cur = assert (dbCon:execute(string.format([[
		select * from users where username = '%s']], user))
	)
	-- row = cur:fetch ({}, "a")	-- the rows will be indexed by field names
	
	local id = assert(cur:fetch({}, "a").userid, "user doesn't exist") --change userid to expire or hwatever
	
	cur:close()
	return id  
end

function processLoginForm(wsapi_env) --doLogin, show logout
	local request  = wsapi.request.new(wsapi_env)

    if (not (request.POST and request.POST.username and request.POST.password and request.POST.origUrl))
    	then
		fwwrt.util.logger("LOG_ERR", "Bad request from '"..wsapi_env.REMOTE_ADDR.."'")
		return 302, redirectHeaders("http://"..hostname.."/?badRequest"), coroutine.wrap(yeldSleep)
    	end

    authorized, message = pcall(checkLogin, request.POST.username)

    if (not authorized)
    	then
		fwwrt.util.logger("LOG_ERR", "Bad login for '"..request.POST.username.."' from '"..wsapi_env.REMOTE_ADDR.."': "..message)
		return showLoginForm(wsapi_env, "badLogin", message)
		end

    if (not fwwrt.iptkeeper.logIpIn(wsapi_env.REMOTE_ADDR, os.time()+60*10))
    	then
		fwwrt.util.logger("LOG_ERR", "Bad login for '"..request.POST.username.."' from '"..wsapi_env.REMOTE_ADDR.."': address unknown")
		return showLoginForm(wsapi_env, "unknownIP")
		end

	local template = fwwrt.util.fileToVariable(webDir.."/showLogout.template")
	
	-- fwwrt.util.logger("LOG_INFO", "User '"..request.POST.username.."' logged in on '"..wsapi_env.REMOTE_ADDR.."'")

	local values = {actionUrl = "https://"..hostname.."/"
	               ,origUrl   = request.POST.origUrl
	               }
	
	local process = function ()
	    yeldSleep()
		coroutine.yield(cosmo.fill(template, values))
		coroutine.yield("<pre>"..fwwrt.util.printTable(wsapi_env, "rwsapi_env", ".", 10).."</pre>")
		coroutine.yield("<pre>"..fwwrt.util.printTable(request,   "request",    ".", 10).."</pre>")
		end
	
	return 200, commonHeaders, coroutine.wrap(process)
	end

