----------------------------------
---! 启动配置文件
----------------------------------
local _root		= "./"

---! skynet 安装目录
local _skynet	= _root.."3rd/skynet/"

----------------------------------
---!  skynet用到的六个参数
----------------------------------
---!  工作线程数
thread      = 4
---!  服务模块路径（.so)
cpath       = _skynet.."cservice/?.so"
---!  港湾ID，用于分布式系统，0表示没有分布
harbor      = 0
---!  后台运行用到的 pid 文件
daemon      = nil
---!  日志文件
 logger      = nil
--logger      = _root .. "logs/game.log"
---!  初始启动的模块
bootstrap   = "snlua bootstrap"

---!  snlua用到的参数
lua_path    = _skynet.."lualib/?.lua;".._root.."lualib/?.lua"
lua_cpath   = _skynet.."luaclib/?.so;".._root.."luaclib/?.so"
luaservice  = _skynet.."service/?.lua;".. _root .. "service/?.lua"
lualoader   = _skynet.."lualib/loader.lua"
start       = "main"

---!  snax用到的参数
snax    = _skynet.."service/?.lua"



---游戏端口配置

max_client   = 10000         --socket 最大连接数
tcp_port     = 8888          --tcp socket端口
ws_port      = 7777          --web socket端口
debug_port   = 8000          --DEBUG 端口
socket_mode  = 2             -- 0 tcp 1 web 2 混合

---数据库
mongodb_ip      = "127.0.0.1"
mongodb_port    = 27017
mongodb_dbname  = "poker"
mongodb_auth    = ""
mongodb_pwd     = ""



