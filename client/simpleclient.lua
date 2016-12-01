local PATH,IP = ...

IP = IP or "127.0.0.1"

package.path = string.format("%s/client/?.lua;%s/skynet/lualib/?.lua", PATH, PATH)
package.cpath = string.format("%s/skynet/luaclib/?.so;%s/lsocket/?.so", PATH, PATH)

local socket = require "simplesocket"
local message = require "simplemessage"

message.register(string.format("%s/proto/%s", PATH, "proto"))

message.peer(IP, 5678)
message.connect()

local event = {}

message.bind({}, event)

current_userid = "tester"..os.date("%H%M%S")

function event:__error(what, err, req, session)
	print("error", what, err)
end

function event:ping( )	
	n = 3
	print("ping end")
	-- os.execute("sleep " .. n)	
    --	message.request ("ping")
end
-- add 
function event:record(req )	
	n = 3
	print("record  ")
	 os.execute("sleep " .. n)	
	message.request ("record",{userid=current_userid,content= ("I'm "..current_userid.." now is  "..os.date("%H%M%S"))})
end
-- end add 
 
--add 20161201
function event:lotterydraw(_, resp )	
	if resp.item~="nothing" then
	 print("wow ! "..resp.item )
	end
	n = 0.1
	--print("lotterydraw  ")
	 os.execute("sleep " .. n)		 
		message.request("lotterydraw" )
end
--end add 20161201
function event:signin(req, resp)
	print("signin", req.userid, resp.ok)
	if resp.ok then
		-- commit
		  message.request "ping"	-- should error before login
		-- end commit
		
		 message.request "login"
	else
		-- signin failed, signup
	--	message.request("signup", { userid = current_userid,pwd= current_userid})
	end
end

function event:signup(req, resp)
	print("signup", resp.ok)
	if resp.ok then
		message.request("signin", { userid = req.userid })
	else
		error "Can't signup"
	end
end

function event:login(_, resp)
	print("login", resp.ok)
	if resp.ok then
		
		 print("test lotterydraw" )
		 message.request("lotterydraw")

		-- add test record
		--print("test drawq" )
		--message.request("record", { content = " content !" })
		-- end add 
		-- comment
		--message.request "ping"
		-- comment end
	else
		error "Can't login"
	end
end

function event:push(args)
	print("server push", args.text)
end

message.request("signin", { userid =current_userid,pwd=current_userid})

while true do
	message.update()
end
