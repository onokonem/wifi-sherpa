module("luci.controller.myapp.mymodule", package.seeall)

--function enable()
--end

function index()
--    entry({"call", "indexfunc"}, call("action_tryme"), "Click here", 10).dependent=false
--    entry({"call", "lua", "template"}, template("myapp-mymodule/helloworld"), "Hello world", 20).dependent=false
--entry({"cardgen"}, cbi("myapp-mymodule/netifaces"), "Card generating", 30).dependent=false

entry({"call", "lua", "template"}, template("fwwrt-face/login"), "Please logg in", 20).dependent=false
end
 
function action_tryme()
    luci.http.prepare_content("text/plain")
    luci.http.write("Haha, rebooting now...")
end