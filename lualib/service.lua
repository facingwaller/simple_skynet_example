local skynet = require "skynet"
local log = require "log"
--2016112901
--
local service = {}

function service.init(mod)
	--2016112901
	--log("mod.info=[%s],mod.command=[%s],mod.require=[%s],mod.data=[%s]",mod.info,mod.command,mod.require,mod.data)
	--tmp_tb={mod.info,mod.command,mod.require,mod.data}
	 --type(mod.command)
	 
 
	--2016112901
	local funcs = mod.command
	
	if mod.info then
		skynet.info_func(function()
			return mod.info
		end)
	end
	skynet.start(function()
		if mod.require then
			local s = mod.require
			for _, name in ipairs(s) do
					--2016112901
					log("register service=[%s]",name)
					--2016112901
				service[name] = skynet.uniqueservice(name)
			end
		end
		if mod.init then
			mod.init()
		end
		
		skynet.dispatch("lua", function (_,_, cmd, ...)
			local f = funcs[cmd]
			if f then
		--2016112901
			log("invoke function=[%s]",cmd)
		--2016112901
				skynet.ret(skynet.pack(f(...)))
			else
				log("Unknown command : [%s]", cmd)
				skynet.response()(false)
			end
		end)
			
	end)
end

return service
