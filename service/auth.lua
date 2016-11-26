local skynet = require "skynet"
local service = require "service"
local client = require "client"
local log = require "log"

local auth = {}
local users = {}
local cli = client.handler()

local SUCC = { ok = true }
local FAIL = { ok = false }
-- add ender
function CountTB (tb)
 local count = 0
  if  tb  then
	for v in pairs(tb) do
		count=count+1
	end
   end
	return count
end
-- end
function cli:signup(args)
	log("signup userid = %s", args.userid)
	if users[args.userid] then
		return FAIL
	else
		users[args.userid] = true
		--print (" signup users :"..CountTB(tb)) -- 打印当前人数
		return SUCC
	end
end

function cli:signin(args)
	log("signin userid = %s", args.userid)
	if users[args.userid] then
		self.userid = args.userid
		self.exit = true
		--print (" signin users :"..CountTB(tb)) -- 打印当前人数
		return SUCC
	else
		return FAIL
	end
end

function cli:ping()
	log("ping")
end
-- add 
function cli:record(args)
	log("record")	 
end
-- end add
function auth.shakehand(fd)
	local c = client.dispatch { fd = fd }
	return c.userid
end

service.init {
	command = auth,
	info = users,
	init = client.init "proto",
}
