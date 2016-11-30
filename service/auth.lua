local skynet = require "skynet"
local service = require "service"
local client = require "client"
local log = require "log"

local auth = {}
local users = {}
local cli = client.handler()

local SUCC = { ok = true }
local FAIL = { ok = false }


function cli:signup(args)
	log("signup userid = %s", args.userid)
	if users[args.userid] then
		return FAIL
	else
		users[args.userid] = true
	 
		return SUCC
	end
end

function cli:signin(args)
	log("signin userid = %s", args.userid)
	if args.userid == args.pwd then
		self.userid = args.userid
		self.exit = true
 
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

-- add 2016113001
--drawconfig drawconfig/%s wait to put it into a common helper moudle
 function loadconfig(name)
	local file = io.open(name)
	io.close()
	local kvs={}
	for line in file:lines() do
          name,pwd=  string.match(line,"(.*),(.*)")
	 	kvs[name]=pwd
		  --print (name.."_"..pwd)
    --print(line) -- 这里就是每次取一行
	end
	return kvs
end

function printTable( tb)
	for key,value in pairs(tb) do
		print (key..","..value)
	end
end


users={}
users=loadconfig("account")
printTable(users)
--end  add 2016113001