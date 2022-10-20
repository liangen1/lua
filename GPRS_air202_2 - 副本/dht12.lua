---@diagnostic disable: undefined-global, deprecated, lowercase-global
--- 模块功能：dht12温湿度传感器  （有点问题）


module(..., package.seeall)
require "utils"
require "common"
require "ntp"

t=0
h =0
ntp.timeSync(1)
pm.wake("WORK") -- 模块保持唤醒
local i2cId = 2 -- core 0025版本之前，0、1、2都表示i2c 2
-- core 0025以及之后的版本，1、2、3分别表示i2c 1、2、3

local function crc_8(data) -- SHT30获取温湿度结果crc校验
    local crc = 0xFF
    local len = #data
    for i = 1, len do
        crc = bit.bxor(crc, data[i])
        for j = 1, 8 do
            crc = crc * 2
            if crc > 0x100 then
                crc = bit.band(bit.bxor(crc, 0x31), 0xff)
            end
        end
    end
    return crc
end
i2c.send(2, 0x44, {0x30, 0xA2}) 
-- sys.taskInit(
    function dht12_s()
    -- sys.wait(5000)
    -- while true do
        local s = i2c.setup(i2cId, 1000000) -- 打开I²C通道
        -- 定义局部变量，用以保存温度值和湿度值
        local tempCrc = {} -- 定义局部表，保存获取的温度数据，便于进行crc校验
        local humiCrc = {} -- 定义局部表，保存获取的湿度数据，便于进行crc校验
    
        i2c.send(2, 0x44, {0xD2, 0x08})
        local r0 = i2c.recv(2, 0x44, 3) -- 读取数据采集结果
        
        -- b：温度高八位     c：温度低八位    d：b和c的crc校验值     e：湿度高八位      f：湿度低八位       g：e和f的crc校验值
        local __,a1, b0, c0  = pack.unpack(r0, "b3")
        rtos.sleep(100) -- 等待采集

        i2c.send(2, 0x44, {0xD2, 0x09})
        local r0 = i2c.recv(2, 0x44, 3) -- 读取数据采集结果
        
        -- b：温度高八位     c：温度低八位    d：b和c的crc校验值     e：湿度高八位      f：湿度低八位       g：e和f的crc校验值
        local __,a2, b0, c0  = pack.unpack(r0, "b3")
        rtos.sleep(100) -- 等待采集
        i2c.send(2, 0x44, {0xD2, 0x10})
        local r1 = i2c.recv(2, 0x44, 3) -- 读取数据采集结果
        
        -- b：温度高八位     c：温度低八位    d：b和c的crc校验值     e：湿度高八位      f：湿度低八位       g：e和f的crc校验值
        local __,a3, b0, c0  = pack.unpack(r1, "b3")
        rtos.sleep(100) -- 等待采集
        i2c.send(2, 0x44, {0xD2, 0x11})
        local r2 = i2c.recv(2, 0x44, 3) -- 读取数据采集结果
        
        -- b：温度高八位     c：温度低八位    d：b和c的crc校验值     e：湿度高八位      f：湿度低八位       g：e和f的crc校验值
        local __,a4, b0, c0  = pack.unpack(r2, "b3")
        rtos.sleep(100) -- 等待采集

        i2c.send(2, 0x44, {0x2c, 0x10}) 
        rtos.sleep(100)
        local r = i2c.recv(2, 0x44, 6)  -- - 读取数据采集结果
        -- b：温度高八位     c：温度低八位    d：b和c的crc校验值     e：湿度高八位      f：湿度低八位       g：e和f的crc校验值
        local a, b, c, d, e, f, g = pack.unpack(r, "b6")
        table.insert(tempCrc, b) -- 将温度高八位和温度低八位存入表中，稍后进行crc校验
        table.insert(tempCrc, c)
        table.insert(humiCrc, e) -- 将湿度高八位和湿度低八位存入表中，稍后进行crc校验
        table.insert(humiCrc, f)
        -- log.info("SHUJU",b,c,d, e,f, g,a1*256+a3, a2*256+a4)
        local result1 = crc_8(tempCrc) -- 温度数据crc校验
        local result2 = crc_8(humiCrc) -- 湿度数据crc校验

        if d == result1 and g == result2 then
            t = -220+bit.bor(bit.lshift(b,8), c)/256 -- 根据SHT30传感器手册给的公式计算温度和湿度
            h = 30+((bit.bor(bit.lshift(e,8), f)-a2*256+a4)*60)/((a1*256+a3)-(a2*256+a4))
            t = string.format("%.01f", t)
            -- t = string.format("%d", t)
            h = string.format("%d", h)
            -- log.warn("这里是温度", t) -- 打印温度
            -- log.warn("这里是湿度", h) -- 打印湿度
            -- mqtt_s.send_mqtt({wendu=t})
            -- mqtt_s.send_mqtt({shidu=t})
        else
            log.warn("crc_lose")
        end 
    end
-- end)
sys.timerLoopStart(dht12_s,5000)

