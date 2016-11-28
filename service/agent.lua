local skynet = require "skynet"
local service = require "service"
local client = require "client"
local log = require "log"

-- add 2016112802  show each user talks
local users = {}
local talk_index=0
-- end add 2016112802
--add [total users] 20161127 
	totalUsers=0 
-- end add [total users] 20161127

local agent = {}
local data = {}
local cli = client.handler()
 


function cli:ping()
	--assert(self.login)
	--log ("%s ping",data.userid)
	--client.push(self, "push", { text = ("ping received!"..os.date("%H%M%S")) })	-- push message to client
	
end

-- add 
function cli:record(args)
	assert(self.login)
	log ("%s: %s [fd=%s]",users[self.fd],args.content,self.fd) -- 	 2016112802 users[self.fd] is the true userid
	--add 2016112802
	for key,v in pairs(users) do	
		log ("k is %s",key)
		if key  ~= self.fd then 
		 
		 -- print ("self.fd is "..self.fd)  ok
		 -- print ("users[self.fd] is "..users[self.fd])  bad
		  --  log ("self.fd=%s,users[self.fd]=%s,{%s,%s}",self.fd,users[self.fd],args.userid,args.content)
			log ("{%s,%s}", args.userid,args.content)
		  client.pushbyfd(key, "push", { text = ( args.content ) })	-- push message to client
		end
	end
	--end add 2016112802
	
	--client.push(self, "push", { text = ("received" ) })	-- push message to client
	
	 
end
 

 

function cli:login()
	assert(not self.login)
	if data.fd then
		--log("login fail %s fd=%d", data.userid, self.fd) --comment 2016112701	
		  --return { ok = false }  --comment 2016112701	
	end
	data.fd = self.fd
	self.login = true
	log("login succ %s fd=%d", data.userid, self.fd)
	--add total users 20161127
	 -- totalUsers = totalUsers + 1  
	--local l_totalUsers= sharedata.query("totalUsers")
	--totalUsers = totalUsers +1
 	--l_totalUsers=l_totalUsers.."0"
  -- sharedatad.update("totalUsers",l_totalUsers)
  -- client.totalUsers =client.totalUsers +1
	
	 totalUsers=totalUsers+1
	
-- end add 
	client.push(self, "push", { text = "welcome total users="..totalUsers  })	-- push message to client
	return { ok = true }
end

local function new_user(fd)
	local ok, error = pcall(client.dispatch , { fd = fd })
	log("fd=%d is gone. error = %s", fd, error)
	client.close(fd)
	if data.fd == fd then
		data.fd = nil
		skynet.sleep(1000)	-- exit after 10s
		if data.fd == nil then
			-- double check
			if not data.exit then
				data.exit = true	-- mark exit
				skynet.call(service.manager, "lua", "exit", data.userid)	-- report exit
				log("user %s afk", data.userid)
				skynet.exit()
			end
		end
	end
end

function agent.assign(fd, userid)
	if data.exit then
		return false
	end
	--if data.userid == nil then
		data.userid = userid
		--add 2016112802
		log ("users[fd=%s]=userid(%s) ",fd ,userid)
		 users[fd]=userid --add  2016112802
		--end add 2016112802
	--end
	--assert(data.userid == userid)-- comment 2016112701	 assert the same user
	skynet.fork(new_user, fd)
	return true
end
  
 
service.init {
	command = agent,
	info = data,
	require = {
		"manager",
	},
	init = client.init "proto",
}
 
   

