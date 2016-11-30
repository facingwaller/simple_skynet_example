local skynet = require "skynet"
local socket = require "socket"
local log = require "log"

--local  auth = require "auth"

local hub={}

function hub.open(ip,port)
	log("mybub->open listen %s:%d",ip,port)
	data.fd=socket.listen(ip,port)
	data.ip=ip
	data.port=port
	socket.start(data.fd,new_socket)
end

function new_socket(fd,addr)
	log("mybub->new_socket   %s:%s",ip,addr)
	pcall(auth_socket,fd)
	  
end

 
function auth_socket(fd)
 return (skynet.call(service.auth, "lua", "shakehand" , fd))
end

function assign_agent(fd)
	--
end

skynet.start(function()	
	skynet.uniqueservice("auth")
	skynet.uniqueservice("manager")		
end)
