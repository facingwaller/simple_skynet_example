local skynet = require "skynet"

 


skynet.start(function()
    log("Server start")	
	local myhub=skynet.uniqueservice "myhub"-- 
	skynet.call(hub,"lua","open","0.0.0.0",6789)
	skynet.exit()		
end
)