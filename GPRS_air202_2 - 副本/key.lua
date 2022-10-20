---@diagnostic disable: deprecated, undefined-global, lowercase-global

module(...,package.seeall)
-- require "mqtt"
require"pins"
require "common"
require "dht12"


pmd.ldoset(5,pmd.LDO_VMMC)
--GPIO1配置为输出，默认输出低电平，可通过setGpio1Fnc(0或者1)设置输出电平
setkey0 = pins.setup(pio.P0_29,0)
setkey1 = pins.setup(pio.P0_10,0)
setkey2 = pins.setup(pio.P0_11,0)
setkey3 = pins.setup(pio.P0_12,0)
h={0,0,0,0}
m={0,0,0,0}
local key_flag0 = 0 --是否进入调时系统
local key_time = 0 --
local xianshi = 0
local shidu0=0
local wendu0=0


function clockDemo(...)--oled 显示内容
    if key_flag0==0  then
    -- dht12.dht12_s()
    -- local WIDTH, HEIGHT = disp.getlcdinfo()
    disp.clear()
    -- disp.drawrect(0,0,128,13,0xff)
    -- disp.drawrect(0,0,128,13,0xf)
    -- log.info("key",dht12.t)
    local c = misc.getClock()
    disp.update()
    local date = string.format('%04d/%02d/%02d %02d:%02d', c.year, c.month, c.day, c.hour, c.min)
    -- local time = string.format('')
    disp.puttext((date), 0, 0)
    -- disp.puttext(common.utf8ToGb2312(time), getxpos(WIDTH, common.utf8ToGb2312(time)), 24)
    -- disp.puttext(common.utf8ToGb2312("LuatBoard-Air202"), getxpos(WIDTH, common.utf8ToGb2312("LuatBoard-Air202")), 44)
    --刷新LCD显示缓冲区到LCD屏幕上
    disp.puttext("  T:"..dht12.t.."  H:"..dht12.h, 0, 17)
    disp.puttext(string.format("Time1:%d  Time2:%d", time_s.time_s[1]>0 and 1 or 0,time_s.time_s[2]>0 and 1 or 0),0, 36)
    disp.puttext(string.format("Time1:%d  Time2:%d", time_s.time_s[3]>0 and 1 or 0,time_s.time_s[4]>0 and 1 or 0), 0, 50)
    disp.update()
    -- http_s.ss("wendu",dht12.t)
    -- http_s.ss("shidu",dht12.h)
    -- http_s.swt("wendu",dht12.t,"shidu",dht12.h)
    
    if wendu0~=dht12.t or shidu0~=dht12.h then
        wendu0=dht12.t
        shidu0=dht12.h
        sys.publish("pub_msg", json.encode({wendu=wendu0,shidu=shidu0}))
    end
    end
end
--GPIO中断函数
function keyint0(msg)
    --cpu.INT_GPIO_NEGEDGE 下降  cpu.INT_GPIO_POSEDGE 上升沿
    if msg==cpu.INT_GPIO_NEGEDGE then
    -- 上升沿中断
    if(key_flag0 == 0)then
        -- log.info("xxx",pio.pin.getval(pio.P0_29))
    setkey0(pio.pin.getval(pio.P0_29)==0 and 1 or 0)
    sys.publish("pub_msg", json.encode({sw00=pio.pin.getval(pio.P0_29)}))
    else
        key_time = 1
        -- log.info("key_time",key_time)
        keyint4(3)
    end

end
end
function keyint1(msg)
    --cpu.INT_GPIO_NEGEDGE 下降  cpu.INT_GPIO_POSEDGE 上升沿
    if msg==cpu.INT_GPIO_NEGEDGE then
    -- 上升沿中断
    if(key_flag0 == 0)then
    setkey1(pio.pin.getval(pio.P0_10)==0 and 1 or 0)
    sys.publish("pub_msg", json.encode({sw01=pio.pin.getval(pio.P0_10)}))
    -- http_s.ss("sw01",pio.pin.getval(pio.P0_10))
    -- clockDemo()
    else
        key_time = 2
        keyint4(3)
    end
end
end
function keyint2(msg)
    --cpu.INT_GPIO_NEGEDGE 下降  cpu.INT_GPIO_POSEDGE 上升沿
    if msg==cpu.INT_GPIO_NEGEDGE then
    -- 上升沿中断
    if(key_flag0 == 0)then
    setkey2(pio.pin.getval(pio.P0_11)==0 and 1 or 0)
    sys.publish("pub_msg", json.encode({sw02=pio.pin.getval(pio.P0_11)}))
    -- http_s.ss("sw02",pio.pin.getval(pio.P0_11))
    -- clockDemo()
else
    key_time = 3
    keyint4(3)
    end
end
end
function keyint3(msg)
    --cpu.INT_GPIO_NEGEDGE 下降  cpu.INT_GPIO_POSEDGE 上升沿
    if msg==cpu.INT_GPIO_NEGEDGE then
    -- 上升沿中断
    if(key_flag0 == 0)then
    setkey3(pio.pin.getval(pio.P0_12)==0 and 1 or 0)
    sys.publish("pub_msg", json.encode({sw03=pio.pin.getval(pio.P0_11)}))
    -- http_s.ss("sw03",pio.pin.getval(pio.P0_12))
    -- clockDemo()
else
    key_time = 4
    keyint4(3)
    
    end
end
end
function keyint4(msg)
    --cpu.INT_GPIO_NEGEDGE 下降  cpu.INT_GPIO_POSEDGE 上升沿
    if msg==cpu.INT_GPIO_NEGEDGE then
    -- key_flag0 = key_flag0==0 and 1 or 0
    -- log.info("key4",key_flag0,msg)
        key_flag0 = key_flag0+1
        if(key_flag0>2 or (key_time==0 and key_flag0>1))then
            if key_time~=0 then
                time_s.time_s[key_time] = (h[key_time]*60+m[key_time])*60
                if key_time==1 then
                    sys.publish("pub_msg", json.encode({T0=key.h[key_time]..":"..key.m[key_time]}))
                    -- http_s.sss("T0",key.h[key_time]..":"..key.m[key_time])
                end
                if key_time==2 then
                    sys.publish("pub_msg", json.encode({T1=key.h[key_time]..":"..key.m[key_time]}))
                    -- http_s.sss("T1",key.h[key_time]..":"..key.m[key_time])
                end
                if key_time==3 then
                    sys.publish("pub_msg", json.encode({T2=key.h[key_time]..":"..key.m[key_time]}))
                    -- http_s.sss("T2",key.h[key_time]..":"..key.m[key_time])
                end
                if key_time==4 then
                    sys.publish("pub_msg", json.encode({T3=key.h[key_time]..":"..key.m[key_time]}))
                    -- http_s.sss("T3",key.h[key_time]..":"..key.m[key_time])
                end
            end
            key_flag0 = 0
            key_time = 0
            clockDemo()
        end
        if key_flag0==2 and key_time>0 then
            disp.clear()
            disp.puttext("  Ttmer_m : "..m[key_time], 0, 25)
            disp.update()
        end
        if key_flag0==1 then
            disp.clear()
            local date = string.format('输入需要定时的键')
            local date1 = string.format('    再按一次退出')
            disp.puttext(common.utf8ToGb2312(date), 0, 5)
            disp.puttext(common.utf8ToGb2312(date1), 0, 35)
            disp.update()
        end
    end
    if msg==3 then
        disp.clear()
        disp.puttext("  Ttmer_h : "..h[key_time], 0, 25)
        disp.update()
        log.info("key4",key_flag0,msg)
        h[key_time] = 0 
        m[key_time] = 0 
    end
end
function keyint5(msg)
    --cpu.INT_GPIO_NEGEDGE 下降  cpu.INT_GPIO_POSEDGE 上升沿
    if msg==cpu.INT_GPIO_NEGEDGE then
    -- 上升沿中断
    -- log.info("key5")
        if key_flag0==0 then
            --进入时间剩余查询
            xianshi=xianshi==0 and 1 or 0
            if(xianshi==1)then
                -- log.info("s00",xianshi)
                disp.clear()
                local date = string.format('定时器剩余时间:' )
                local tr0 = string.format('T1:%02d:%02d',h[1],m[1] )
                local tr1 = string.format('T2:%02d:%02d',h[2],m[2] )
                local tr2 = string.format('T3:%02d:%02d',h[3],m[3] )
                local tr3 = string.format('T4:%02d:%02d',h[4],m[4] )
                disp.puttext(common.utf8ToGb2312(date), 0, 0)
                disp.puttext(common.utf8ToGb2312(tr0)..common.utf8ToGb2312(tr1), 0, 18)
                disp.puttext(common.utf8ToGb2312(tr2)..common.utf8ToGb2312(tr3), 0, 43)
                disp.update()
            else
                clockDemo()--oled 显示内容
                --退出显示
            end
        end
        if key_time>0 then
            if key_flag0==1 then
                h[key_time] = h[key_time]+1
                -- log.info("s",h[key_time])
                disp.clear()
                disp.puttext("  Ttmer_h : "..h[key_time], 0, 25)
                disp.update()
            end
            if key_flag0==2 then
                m[key_time] = m[key_time]+1
                -- log.info("sm",m[key_time])
                disp.clear()
                disp.puttext("  Ttmer_m : "..m[key_time], 0, 25)
                disp.update()
            end
        end  
    end
end

-- interrupt  
--配置GPIO为中断，
pins.setup(pio.P0_0,keyint4,pio.PULLUP)
pins.setup(pio.P0_1,keyint5,pio.PULLUP)
pins.setup(pio.P0_2,keyint1,pio.PULLUP)
pins.setup(pio.P0_3,keyint0,pio.PULLUP)
pins.setup(pio.P0_4,keyint3,pio.PULLUP)
pins.setup(pio.P0_5,keyint2,pio.PULLUP)

sys.timerLoopStart(clockDemo,10000)
