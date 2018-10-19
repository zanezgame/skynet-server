local skynet = require "skynet"
local utils = require "utils"
local protobuf = require "protobuf"

require "skynet.manager"

---! proto的 pb文件
local pb_files = {
    "./proto/login.pb"
}

local CMD = {}

function CMD.init()
    for _, v in ipairs(pb_files) do
        protobuf.register_file(v)
    end
end

function CMD.encode(msg_name, msg)
    skynet.error("encode" .. msg_name)
    utils.print(msg)
    return protobuf.encode(msg_name, msg)
end

function CMD.decode(msg_name, data)
    skynet.error("decode " .. msg_name .. " " .. type(data) .. " " .. #data)
    return protobuf.decode(msg_name, data)
end

function CMD.test()

    local msg = { account = "name", token = "okokok" }

    local data = CMD.encode("Login.c2s_login", msg)

    local de_msg = CMD.decode("Login.s2c_login", data)
    skynet.error(de_msg.account)
end

local dispatch = function(session, address, command, ...)
    local f = CMD[command]
    if not f then
        skynet.ret(skynet.pack(nil, "Invalid command" .. command))
    end

    if command == "decode" then
        local name
        local buf
        name, buf = ...
        skynet.ret(skynet.pack(CMD.decode(name, buf)))
        return
    end
    local ret = f(...)
    skynet.ret(skynet.pack(ret))
end

skynet.start(function()

    CMD.init()

    skynet.dispatch("lua", dispatch)

    skynet.register("pbc")

    --skynet.call(skynet.self(),"lua","test")
end)
