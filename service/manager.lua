local skynet = require "skynet"
local service = require "service"
local log = require "log"

local manager = {}
local users = {}

local function new_agent()
	-- todo: use a pool
	return skynet.newservice "agent"
end

local function free_agent(agent)
	-- kill agent, todo: put it into a pool maybe better
	skynet.kill(agent)
end

function manager.assign(fd, userid)
	local agent
	repeat
		--add [total users] 2016112701
		-- end add [total users] 2016112701		
		agent = users[0]-- agent = users[userid] comment
		if not agent then
			agent = new_agent()
			if not  users[0] then
				-- double check
				users[0] = agent  -- users[userid] = modify 2016112701				
			else
			  free_agent(agent)
		       agent = users[0] 	--	agent = users[userid] modify 2016112701
				 
			end
		end
	until skynet.call(agent, "lua", "assign", fd, userid)
	log("Assign %d to %s [%s]", fd, userid, agent)
end

function manager.exit(userid)
	users[userid] = nil
end

service.init {
	command = manager,
	info = users,
}


