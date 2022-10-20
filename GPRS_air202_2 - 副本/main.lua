---@diagnostic disable: undefined-global
--必须在这个位置定义PROJECT和VERSION变量
--PROJECT：ascii string类型，可以随便定义，只要不使用,就行
--VERSION：ascii string类型，如果使用Luat物联云平台固件升级的功能，必须按照"X.X.X"定义，X表示1位数字；否则可随便定义
PROJECT = "GPIO_SINGLE"
VERSION = "2.0.0"

require "log"
require "sys"
require "net"
require "netLed"
require "errDump"
require "ssd1306"
require "key"
require "mqtt_s"
-- require "http_s"
require "time_s"


LOG_LEVEL = log.LOGLEVEL_TRACE

--每1分钟查询一次GSM信号强度
--每1分钟查询一次基站信息
net.startQueryAll(60000, 60000)
netLed.setup(true,pio.P1_1)
errDump.request("udp://ota.airm2m.com:9072")

--加载远程升级功能模块【强烈建议打开此功能】
--如下3行代码，只是简单的演示如何使用update功能，详情参考update的api以及demo/update
--PRODUCT_KEY = "v32xEAKsGTIEQxtqgwCldp5aPlcnPs3K"
--require "update"
--update.request()

--加载GPIO功能测试模块

key.clockDemo()

--启动系统框架
sys.init(0, 0)
sys.run()
