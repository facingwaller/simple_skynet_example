local skynet = require "skynet"
local service = require "service"
local client = require "client"
local log = require "log"

--2016113001 lucky draw

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
 
--add 20161201
function cli:lotterydraw( )
	assert(self.login)
	--log ("%s:  [fd=%s] draw ",users[self.fd],self.fd) 
	--print ("  draw "..self.fd.." userid="..users[self.fd]) 
	
	--client.pushbyfd(key, "push", { text = ( args.content ) })	
	local result=Serverlotterydraw()
		if result then
		print (users[self.fd].." get "..result.."  "..globalindex-1)
		return { item = result} --return item
		else
		--print ("3q "..globalindex-1)
		end	
	return { item = "nothing" }
	--	client.push(self, "push", { text = "welcome total users="..totalUsers  })
end

--end add 20161201
 

function cli:login( )
	assert(not self.login)
	if data.fd then
		--log("login fail %s fd=%d", data.userid, self.fd) --comment 2016112701	
		  --return { ok = false }  --comment 2016112701	
	end
	data.fd = self.fd
	self.login = true
	log("login succ %s fd=%d", data.userid, self.fd)
	--
	--users[self.fd]=args.
	--
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



-- add 20161201
function loadconfigbyformort(name,formort)
	local file = io.open(name)
	io.close()
	local kvs={}
	local item={}
	index=0
	for line in file:lines() do
		itemid1,fenzi1,fenmu1=  string.match(line,"(.*),(.*),(.*)")
		--item.itemid=itmid1
		--item.fenzi=fenzi1
		--item.fenmu=fenmu1
		index=index+1
	 	kvs[index]={itmid=itemid1,fenzi=fenzi1,fenmu=fenmu1}
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
function printTable_luckyitems( tb)
	for key,value in pairs(tb) do
		print (key..","..value.itmid)
	end
end

function printTable3( tb)
	for key,value in ipairs(tb) do
		print (key..","..value)
	end
end

function initluckydraws( _luckyitems)
  --find max fenmu
  max=0
  for key,item in pairs(_luckyitems) do
	 if( tonumber(item.fenmu)>max) then
       max=tonumber(item.fenmu);
	   end
	end
  --maxIndex=max
  math.randomseed(os.time())
    local   tb={}
	--
  for key,item in pairs(_luckyitems) do
      for start=1,max,item.fenmu  do
          repeat
           num=math.random(start,start+item.fenmu)
          until  tb[num]==nil
         tb[num]=item.itmid
      end
	end
	return max,tb
end

function Serverlotterydraw()
	local 	res
	--print (maxIndex.." "..globalindex)
	if(maxIndex==globalindex) then
		globalindex=1
		maxIndex,luckydrawsitems=initluckydraws(luckyitems) --reset
	end
 	 res= luckydrawsitems[globalindex]
	globalindex=globalindex+1
	return res


end

function test_lotterydraw()
	for i=1,maxIndex do
	local result=Serverlotterydraw()

		if result then
		print (result.." "..globalindex-1)
		else
		print ("3q "..globalindex-1)
		end


	end

end
--1 readconfig
--2 init draw
--3 print 2 test1 and 2,and assert shoulud be better
--4 draw
 luckydrawsitems={}
 --luckyitems={item={ itemid ="",fenzi ="",fenmu =""}}
luckyitems={ }
 drawindex=0
 
luckyitems=loadconfigbyformort("drawconfig/luckyitems")
 printTable_luckyitems( luckyitems)

--print ("test luckyitems-----------")
maxIndex,luckydrawsitems=initluckydraws(luckyitems)




 print ("test luckydrawsitems-----------")
 printTable( luckydrawsitems)
globalindex=0
 -- fill in loadconfigbyformort
--test_lotterydraw()

--end add 20161201
 
   

