---@diagnostic disable: deprecated, undefined-global, lowercase-global
require"pins"
module(...,package.seeall)

time_s={0,0,0,0}


local function getket( num )
    -- body
    return pio.pin.getval(num)
end


function time_init()  
    for i=1,4,1 do
        if time_s[i]~=0 then
            time_s[i] = time_s[i]-1
            -- log.info("time",i,time_s[i]) 
            if time_s[i] == 0 then
                key.h[i]=math.floor(time_s[i]/3600)
                key.m[i]=math.ceil(time_s[i]%3600/60)
                if i==1 then
                    key.setkey0(0)
                    key.setkey1(0)
                    -- sys.publish("pub_msg", json.encode({sw00=0,sw01=0}))
                    -- key.setkey0(pio.pin.getval(pio.P0_29)==0 and 1 or 0)
                --     -- http_s.ss("sw00",pio.pin.getval(pio.P0_29))
                    -- sys.publish("pub_msg", json.encode({sw00=pio.pin.getval(pio.P0_29)}))
                --     -- http_s.sss("T0",key.h[i]..":"..key.m[i])
                elseif i==2 then
                    key.setkey0(0)
                    key.setkey1(0)
                    -- sys.publish("pub_msg", json.encode({sw00=0,sw01=0}))
                    -- key.setkey1(pio.pin.getval(pio.P0_10)==0 and 1 or 0)
                --     sys.publish("pub_msg", json.encode({sw01=pio.pin.getval(pio.P0_10)}))
                elseif i==3 then
                    key.setkey2(pio.pin.getval(pio.P0_11)==0 and 1 or 0)
                    sys.publish("pub_msg", json.encode({sw02=pio.pin.getval(pio.P0_11),T2=key.h[i]..":"..key.m[i]}))
                elseif i==4 then
                    -- key.setkey3(pio.pin.getval(pio.P0_12)==0 and 1 or 0)
                --     sys.publish("pub_msg", json.encode({sw03=pio.pin.getval(pio.P0_12)}))
                end
                -- sys.publish("pub_msg",json.encode({sw00 = getket(pio.P0_29),sw01 = getket(pio.P0_10),sw02 = getket(pio.P0_11),
                -- sw03 = getket(pio.P0_12),T0 = key.h[1]..":"..key.m[1],T1 = key.h[2]..":"..key.m[2],
                -- T2 = key.h[3]..":"..key.m[3],T3 = key.h[4]..":"..key.m[4]}))
            end
            if time_s[i]%60==0 and time_s[i]~=0 then
                key.h[i]=math.floor(time_s[i]/3600)
                key.m[i]=math.ceil(time_s[i]%3600/60)
                -- log.info("times",i,time_s[i]%60) 
                -- sys.publish("pub_msg", json.encode({T0=key.h[1]..":"..key.m[1],T1=key.h[2]..":"..key.m[2],T2=key.h[3]..":"..key.m[3],T3=key.h[4]..":"..key.m[4]}))
                if i==1 then
                    -- http_s.sss("T0",key.h[i]..":"..key.m[i])
                    -- sys.publish("pub_msg", json.encode({T0=key.h[i]..":"..key.m[i]}))
                end
                if i==2 then
                    -- sys.publish("pub_msg", json.encode({T1=key.h[i]..":"..key.m[i]}))
                    -- http_s.sss("T1",key.h[i]..":"..key.m[i])
                end
                if i==3 then
                    sys.publish("pub_msg", json.encode({T2=key.h[i]..":"..key.m[i]}))
                    -- http_s.sss("T2",key.h[i]..":"..key.m[i])
                end
                if i==4 then
                    -- sys.publish("pub_msg", json.encode({T3=key.h[i]..":"..key.m[i]}))
                    -- http_s.sss("T3",key.h[i]..":"..key.m[i])
                end
            end  
        end
    end
end


sys.timerLoopStart(time_init,800)

