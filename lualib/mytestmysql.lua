local skynet = require "skynet"
local mysql = require "mysql"

local dal={}
local db
local isconn = false  


  function  dal.conn2mysql()
  db=mysql.connect({
		host="127.0.0.1",
		port=3306,
		database="gamedb",
		user="root",
		password="123456",
		max_packet_size = 1024 * 1024,
		on_connect = on_connect
	})
	if not db then
		print("failed to connect")
	end
	print("testmysql success to connect to mysql server")

end
-----------------------------
 

----
function dal.query(sql)
	--
	--if not isconn then  		dal.conn2mysql()  		isconn=true 	end
	--
	 function on_connect(db1)
	db1:query("set charset utf8")
	end
	
	print ("mysql.connect ")
	 db=mysql.connect({
		host="127.0.0.1",
		port=3306,
		database="gamedb",
		user="root",
		password="123456",
		max_packet_size = 1024 * 1024,
		on_connect = on_connect
	})
	
	if not db then
		print("failed to connect")
	else
		print ("mysql.connect ok ")
	end
	
	print (sql)
	res = db:query(sql)
	print ("query finish")
	--print (res)
	local count=0
	for i,v in pairs(res) do		 				
		-- if type(v) == "table" then
			for i1,v1 in pairs(v) do
				print (i1..","..v1)	
				if v1==1 then
					count=1
				else
					count=0
				end
			end
		--end	 
	end 
	--print (#res)
	--self.dump(res)
	
	--if not res then
	--print ("res not nil ")
	--self.dump(res)
	--	end
	--db.disconnect()
	print ("test for")
	--
	return count
end

function closeconn()
	db.disconnect()
end
------------------------
  function dal.dump(obj)
    local getIndent, quoteStr, wrapKey, wrapVal, dumpObj
    getIndent = function(level)
        return string.rep("\t", level)
    end
    quoteStr = function(str)
        return '"' .. string.gsub(str, '"', '\\"') .. '"'
    end
    wrapKey = function(val)
        if type(val) == "number" then
            return "[" .. val .. "]"
        elseif type(val) == "string" then
            return "[" .. quoteStr(val) .. "]"
        else
            return "[" .. tostring(val) .. "]"
        end
    end
    wrapVal = function(val, level)
        if type(val) == "table" then
            return dumpObj(val, level)
        elseif type(val) == "number" then
            return val
        elseif type(val) == "string" then
            return quoteStr(val)
        else
            return tostring(val)
        end
    end
    dumpObj = function(obj, level)
        if type(obj) ~= "table" then
            return wrapVal(obj)
        end
        level = level + 1
        local tokens = {}
        tokens[#tokens + 1] = "{"
        for k, v in pairs(obj) do
            tokens[#tokens + 1] = getIndent(level) .. wrapKey(k) .. " = " .. wrapVal(v, level) .. ","
        end
        tokens[#tokens + 1] = getIndent(level - 1) .. "}"
        return table.concat(tokens, "\n")
    end
    return dumpObj(obj, 0)
end
----------------------------
return dal



























