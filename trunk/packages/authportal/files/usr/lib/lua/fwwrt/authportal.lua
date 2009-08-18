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
require "fwwrt.dbBackend"

local webDir     = fwwrt.util.uciGet('httpd.httpd.home',            'string')
local hostname   = fwwrt.util.uciGet('fwwrt.authportal.httpsName',  'string')
local loginDelay = fwwrt.util.uciGet('fwwrt.authportal.logindelay', 'number')
local dbFile     = fwwrt.util.uciGet('fwwrt.authportal.dbFile',     'string')
--local ssid       = fwwrt.util.uciGet('wireless.wifi-iface.ssid',  'string')

local statement = {allActive  = [[SELECT DISTINCT
                                  *
                                  FROM       activeusers AS a
                                  INNER JOIN users       AS u ON (u.userid = a.userid)
                                ]]
                  ,oneActive  = [[SELECT DISTINCT
                                  *
                                  FROM       activeusers AS a
                                  INNER JOIN users       AS u ON (u.userid = a.userid)
                                  WHERE a.ipaddr = ?
                                ]]
                  ,userById   = [[SELECT DISTINCT
                                  * 
                                  FROM       users  AS u
                                  INNER JOIN tarifs AS t ON (t.tarifid = u.tarifid)
                                  WHERE u.userid = ?
                                ]]
                  ,updateUser = "UPDATE users totalTimeUsed = ? where userid = ?"
                  ,addActive  = "INSERT INTO activeusers (ipaddr, userid, logintime) VALUES (?,?,?)"
                  ,userByName = [[SELECT DISTINCT
                                  * 
                                  FROM       users  AS u
                                  INNER JOIN tarifs AS t ON (t.tarifid = u.tarifid)
                                  WHERE u.username = ?
                                ]]
                  ,tarifById  = "SELECT * FROM tarifs WHERE tarifid = ?"
                  }

dbCon = fwwrt.dbBackend.connect()

local key, val
for key, val in pairs(statement)
	do
	if (type(val) == 'string')
		then
		statement[key] = dbCon:prepare(val)
		end
	end

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
	local cur
	local userCur
	local userRow
	local reset
	if ip == nil then
		cur = fwwrt.dbBackend.bindAndExecute(statement.allActive, {})
	else
		cur = fwwrt.dbBackend.bindAndExecute(statement.oneActive, {{'TEXT', ip}})
	end
	local row = cur:fetch ({}, "a")	-- the rows will be indexed by field names
	while row do
		reset    = fwwrt.dbBackend.bindAndExecute(statements.updateUser
		                                         ,{{'INTEGER' ,os.time() - row.logintime +row.totalTimeUsed}
		                                          ,{'INTEGER' ,row.userid}
		                                          }
		                                         )
		row = cur:fetch (row, "a")	-- reusing the table of results
	end
	cur:close()
	userCur:close()
	return true
end

function doLogin(ip, userid)
	local cur = fwwrt.dbBackend.bindAndExecute(statements.addActive
	                                          ,{{'TEXT'    ,ip}
	                                           ,{'INTEGER' ,userid}
	                                           ,{'INTEGER' ,os.time()}
	                                           }
	                                          )
	cur:close()
	return true
end

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
	local cur = fwwrt.dbBackend.bindAndExecute(statements.userByName
	                                          ,{{'TEXT', user}}
	                                          )
	-- row = cur:fetch ({}, "a")	-- the rows will be indexed by field names
	
	local info = assert(cur:fetch({}, "a"), "user doesn't exist") --change userid to expire or hwatever
	
	cur:close()
	return info.userid, info.totalTimeUsed, info.totalTimeLim
end

function processLoginForm(wsapi_env) --doLogin, show logout
	local request  = wsapi.request.new(wsapi_env)

    if (not (request.POST and request.POST.username and request.POST.password and request.POST.origUrl))
    	then
		fwwrt.util.logger("LOG_ERR", "Bad request from '"..wsapi_env.REMOTE_ADDR.."'")
		return 302, redirectHeaders("http://"..hostname.."/?badRequest"), coroutine.wrap(yeldSleep)
    end

    local authorized, totalTimeUsed, totalTimeLim = pcall(checkLogin, request.POST.username) -- autorized contains userid

    if (not authorized) then
		fwwrt.util.logger("LOG_ERR", "Bad login for '"..request.POST.username.."' from '"..wsapi_env.REMOTE_ADDR.."': "..totalTimeUsed)
		return showLoginForm(wsapi_env, "badLogin", message)
	end
	

	local expire = os.time() + totalTimeLim - totalTimeUsed
	
    if (not fwwrt.iptkeeper.logIpIn(wsapi_env.REMOTE_ADDR, expire))
    	then
		fwwrt.util.logger("LOG_ERR", "Bad login for '"..request.POST.username.."' from '"..wsapi_env.REMOTE_ADDR.."': address unknown")
		return showLoginForm(wsapi_env, "unknownIP")
	end
	
	doLogin(wsapi_env.REMOTE_ADDR, authorized)
	
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

