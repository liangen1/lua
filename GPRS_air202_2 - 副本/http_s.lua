---@diagnostic disable: deprecated, undefined-global, unused-local, lowercase-global
require "http"
require "sys"
module(..., package.seeall)

function ss(id, num )
    if net.getState()=="REGISTERED" then
        local text =  http.request("POST","http://api.heclouds.com/devices/943068003/datapoints",nil,
        {["api-key"]="LELPGq==83uCERgOFMT=RMH9gbc=" },{[1]='{"datastreams":[{"id":"'..id..'","datapoints":[{"value":'..num..'}]}]}'},
        3000,cbFnc)
    log.info("http",cbFnc)
    end

end
function sss(id, num )
    if net.getState()=="REGISTERED" then
    local text =  http.request("POST","http://api.heclouds.com/devices/943068003/datapoints",nil,
        {["api-key"]="LELPGq==83uCERgOFMT=RMH9gbc=" },{[1]='{"datastreams":[{"id":"'..id..'","datapoints":[{"value":"'..num..'"}]}]}'},
        3000,cbFnc)
    end
    -- log.info("https",cbFnc,'{"datastreams":[{"id":"'..id..'","datapoints":[{"value":"'..num..'"}]}]}')
end
function swt(id0, num0,id1,num1 )
    if net.getState()=="REGISTERED" then
    local text =  http.request("POST","http://api.heclouds.com/devices/943068003/datapoints",nil,
        {["api-key"]="LELPGq==83uCERgOFMT=RMH9gbc=" },{[1]='{"datastreams":[{"id":"'..id0..'","datapoints":[{"value":'..num0..'}]},{"id":"'..id1..'","datapoints":[{"value":'..num1..'}]}]}'},
        3000,cbFnc)
    end
    -- log.info("https",cbFnc,'{"datastreams":[{"id":"'..id..'","datapoints":[{"value":"'..num..'"}]}]}')
end
--sys.timerStart(ss,3000)   --3秒运行一次
-- sys.timerLoopStart (ss("sw00",1),10000)

