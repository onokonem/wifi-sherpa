#!/usr/bin/lua

-- FWWRT project authentication portal
-- Providing HTTP(S) server
-- Loging users in and out, keep dhcp info up to date
--
-- Daniel Podolsky, tpaba@cpan.org, 2009-07-23
-- Licence is the same as OpenWRT

function trace (event)
  local i = debug.getinfo(2)
  print("line "..i.short_src..":"..i.currentline..":"..tostring(i.name))
  io.flush()
end

-- debug.sethook(trace, "c")

require "xavante"
require "xavante.cgiluahandler"
require "wsapi.xavante"
-- require "luci.sgi.wsapi"

require "fwwrt.iptkeeper"
require "fwwrt.util"
require "fwwrt.authportal"
require "fwwrt.basicadmin"

fwwrt.util.initLogger("authportal", "LOG_DAEMON", fwwrt.util.uciGet('fwwrt.log.verbose', 'boolean'), false)

function printInfo(wsapi_env, funcName)
    fwwrt.util.logger("LOG_NOTICE", "  requestHandler  '"..funcName.."' called")

	local headers = { ["Content-type"] = "text/html" }
	
	local function htmlBody()
		coroutine.yield("<html><body>")
		coroutine.yield("<p>Hello Wsapi!</p>")
		coroutine.yield("<p>'"..funcName.."' handler called</p>")
		coroutine.yield("<p>SERVER_PORT: " .. wsapi_env.SERVER_PORT .. "</p>")
		coroutine.yield("<p>PATH_INFO: " .. wsapi_env.PATH_INFO .. "</p>")
		coroutine.yield("<p>SCRIPT_NAME: " .. wsapi_env.SCRIPT_NAME .. "</p>")
		coroutine.yield("</body></html>")
		end

	return 200, headers, coroutine.wrap(htmlBody)
	end
	
function   authHttpHandler  (wsapi_env) return printInfo(wsapi_env, "authHttpHandler")    end
function   authHttpsHandler (wsapi_env) return printInfo(wsapi_env, "authHttpsHandler")   end
function   adminStub        (wsapi_env) return printInfo(wsapi_env, "adminStub")   end

function  callbackHandler   () fwwrt.iptkeeper.updateAccess() return false end

local ssl = {mode        = "server"
            ,protocol    = "sslv23"
            ,key         = fwwrt.util.uciGet('fwwrt.ssl.certificate', 'string')
            ,certificate = fwwrt.util.uciGet('fwwrt.ssl.certificate', 'string')
            ,cafile      = pcall(fwwrt.util.uciGet, 'fwwrt.ssl.cafile', 'string') or nil
            ,verify      = {"none"}
            ,options     = {"all", "no_sslv2"}
            ,ciphers     = fwwrt.util.uciGet('fwwrt.ssl.ciphers', 'string')
            }
 
local webDir = fwwrt.util.uciGet('httpd.httpd.home', 'string')

local adminRule = {match = {"^/admin"}
                  ,with  = wsapi.xavante.makeHandler(fwwrt.basicadmin.processBasicAdminForm, nil, webDir, webDir)
                  }

function catchAll(handler)
	return {match = {"."}
	       ,with  = wsapi.xavante.makeHandler(handler, nil, webDir, webDir)
	       }
	end

local servers = {["*"] = {[fwwrt.util.uciGet('fwwrt.ports.unauth', 'number')] = 
                                   {rules = {catchAll(fwwrt.authportal.showLoginForm)
                                            }
                                   }
                         ,[fwwrt.util.uciGet('fwwrt.ports.unauthSSL', 'number')] = 
                                   {rules = {adminRule
                                            ,catchAll(fwwrt.authportal.processLoginForm)
                                            }
                                   ,ssl   = ssl
                                   }
                         ,[fwwrt.util.uciGet('fwwrt.ports.auth', 'number')] = 
                                   {rules = {catchAll(fwwrt.authportal.processLogoutForm)
                                            }
                                   }
                         ,[fwwrt.util.uciGet('fwwrt.ports.authSSL', 'number')] = 
                                   {rules = {catchAll(fwwrt.basicadmin.processBacisAdminForm)
                                            }
                                   ,ssl   = ssl
                                   }
                         }
                }

for host, ports in pairs(servers)
	do
	for prt, def in pairs(ports)
		do
		xavante.HTTP{server = {host = host, port = prt, ssl = def.ssl}, defaultHost = {rules = def.rules}}
		end
	end

xavante.start(callbackHandler, fwwrt.util.uciGet('fwwrt.authportal.logindelay', 'number') / 2)