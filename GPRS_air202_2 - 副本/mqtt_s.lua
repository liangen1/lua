---@diagnostic disable: deprecated, undefined-global, lowercase-global, undefined-field
require "mqtt"
module(..., package.seeall)

-- 这里请填写修改为自己的IP和端口
local host, port = "183.230.40.39", 6002
mqttc = mqtt.client(设备ID, 120, "产品ID", "APIKey")--设备ID,产品ID，APIKey
local mqtt_flog =0

function str2hex(str)
	--判断输入类型	
	if (type(str)~="string") then
	return nil,"str2hex invalid input type"
	end
	--滤掉分隔符
	str=str:gsub("[%s%p]",""):upper()
	--检查内容是否合法
	if(str:find("[^0-9A-Fa-f]")~=nil) then
	return nil,"str2hex invalid input content"
	end
	--检查字符串长度
	if(str:len()%2~=0) then
	return nil,"str2hex invalid input lenth"
	end
	--拼接字符串
	local index=1
	local ret=""
	for index=1,str:len(),2 do
	ret=ret..string.char(tonumber(str:sub(index,index+1),16))
	end

	return ret
end
function hex2str(hex)
	--判断输入类型
	if (type(hex)~="string") then
		return nil,"hex2str invalid input type"
	end
	--拼接字符串
	-- local index=1
	local ret=""
	for index=1,hex:len() do
		ret=ret..string.format("%02X",hex:sub(index):byte())
	end
	return ret
end
function send_mqtt(dic)
    if mqttc:publish0("$dp",json.encode(dic),0,0)then  
            log.info("消息:", json.encode(dic))
    end
end
local function getket( num )
    -- body
    return pio.pin.getval(num)
end
socket.setSendMode(1)

-- 测试MQTT的任务代码
sys.taskInit(function()
    local LED = pins.setup(pio.P0_8)
    while true do
        while not socket.isReady() do sys.wait(1000) end
        -- local mqttc = mqtt.client(misc.getImei(), 300, "user", "password")
        while not mqttc:connect(host, port) do sys.wait(2000) end
        send_mqtt({sw00 = getket(pio.P0_29),sw01 = getket(pio.P0_10),sw02 = getket(pio.P0_11),
        sw03 = getket(pio.P0_12),T2 = key.h[3]..":"..key.m[3],T3 = key.h[4]..":"..key.m[4]})
        
        if mqttc:subscribe(string.format("$crsp/cmduuid", 0)) then
            LED(0)
            -- if mqttc:publish(string.format("/device/%s/report", misc.getImei()), "test publish " .. os.time()) then
                while true do
                    local r, data, param = mqttc:receive(120000, "pub_msg")
                    if r then
                        -- log.info("这是收到了服务器下发的消息:", data.payload or "nil",json.decode(data.payload)["sw00"])
                        -- mqttc:publish0("$dp",data.payload,0,0)--
                        local a = json.decode(data.payload)
                        if a["sw00"]~=nil then
                            -- key.setkey0(a["sw00"])
                            key.setkey0(0)--2
                            key.setkey1(a["sw00"])--2
                            -- time_s.time_s[1] = (key.h[1]*60+key.m[1])
                            -- send_mqtt({sw01=0,sw00=a["sw00"]})--
                            -- mqttc:publish0("$dp",data.payload,0,0)
                        end
                        if a["sw01"]~=nil then
                            -- time_s.time_s[2] = (key.h[1]*60+key.m[1])
                            key.setkey0(a["sw01"])--2
                            key.setkey1(a["sw01"])
                            -- send_mqtt({sw00=0,sw01=a["sw01"]})--
                            -- mqttc:publish0("$dp",data.payload,0,0)
                        end
                        if a["sw02"]~=nil then
                            key.setkey2(a["sw02"])
                            send_mqtt({sw02=a["sw02"]})
                            mqttc:publish0("$dp",data.payload,0,0)
                        end
                        if a["sw03"]~=nil then
                            key.setkey3(a["sw03"])
                        end
                        if a["T0"]~=nil then
                            -- time_s.time_s[1]=(string.format("%d",string.sub(a["T0"],1,2))
                            -- +string.format("%d",string.sub(a["T0"],4,5)))*60
                            key.h[1]=tonumber(a["T0"]:split(':')[1])
                            key.m[1]=tonumber(a["T0"]:split(':')[2])
                            time_s.time_s[1] = (key.h[1]*60+key.m[1])
                            mqttc:publish0("$dp",json.encode({T0=key.h[1]..":"..key.m[1]}),0,0)
    
                            -- log.info('aaaa',string.format("%d",string.sub(a["T0"],1,2)),
                            -- string.sub(a["T0"],1,2),string.sub(a["T0"],4,5))
                            -- key.setkey0(a["T0"])
                        end                        
                        if a["T1"]~=nil then
                            key.h[2]=tonumber(a["T1"]:split(':')[1])
                            key.m[2]=tonumber(a["T1"]:split(':')[2])
                            time_s.time_s[2] = (key.h[2]*60+key.m[2])
                            mqttc:publish0("$dp",json.encode({T1=key.h[2]..":"..key.m[2]}),0,0)
                            -- key.setkey1(a["T1"])
                        end
                        if a["T2"]~=nil then
                            key.h[3]=tonumber(a["T2"]:split(':')[1])
                            key.m[3]=tonumber(a["T2"]:split(':')[2])
                            time_s.time_s[3] = (key.h[3]*60+key.m[3])*60
                            mqttc:publish0("$dp",json.encode({T2=key.h[3]..":"..key.m[3]}),0,0)
                            -- key.setkey2(a["T2"])
                        end
                        if a["T3"]~=nil then
                            key.h[4]=tonumber(a["T3"]:split(':')[1])
                            key.m[4]=tonumber(a["T3"]:split(':')[2])
                            time_s.time_s[4] = (key.h[4]*60+key.m[4])*60
                            -- key.setkey3(a["T3"])
                        end
                        -- mqttc:publish("$dp",data.payload ,0)
                    elseif data == "pub_msg" then
                        -- log.info("这是收到了订阅的消息和参数显示:", data, param)
                        -- send_mqtt(param)
                        mqttc:publish0("$dp",param,0,0)
                    elseif data == "timeout" then
                        log.info("这是等待超时主动上报数据的显示!")
                        -- mqttc:publish(string.format("/device/%s/report", misc.getImei()), "test publish " .. os.time())
                    else
                        break
                    end
                end
            -- end
        end
        mqttc:disconnect()
    end
end)

-- -- 测试代码,用于发送消息给socket
-- sys.taskInit(function()
--     while true do
--         sys.publish("pub_msg", json.encode({time=1}))
--         -- log.info("pub_msg", "nihao" .. os.time())
--         -- 
--         sys.wait(10000)
--     end
-- end)
