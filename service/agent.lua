local skynet = require "skynet"
local websocket = require "websocket"
local socket = require "socket"
local protopack = require "protopack"
local protodefine = require "protodefine"

local watchdog
local CMD = {}
local client_fd
local socket_type = 0

skynet.register_protocol {
    name = "client",
    id = skynet.PTYPE_CLIENT,
    unpack = skynet.tostring,
}

function CMD.start(conf)
    local fd = conf.client
    local gate = conf.gate
    watchdog = conf.watchdog
    socket_type = conf.socket_type
    client_fd = fd
    skynet.call(gate, "lua", "forward", fd)
end

function CMD.disconnect()
    -- todo: do something before exit
    skynet.exit()
end

function CMD.sendData (mainId, subId, body)

    local data = { mainId = mainId, subId = subId, body = body }
    local packet = protopack.main_pack(data)

    if socket_type == 0 then
        socket.write(client_fd, string.pack(">s2", packet))
    elseif socket_type == 1 then
        websocket.send_binary(client_fd, packet)
    end

end

local socket_dispatch = function(_, _, command, ...)

    skynet.error(command)
    local f = CMD[command]
    assert(f, "Invalid command")
    skynet.ret(skynet.pack(f(...)))

end

local client_dispatch = function(_, _, data)

    local args = protopack.main_unpack(data)

    if (args ~= false and args.mainId ~= nil and args.mainId > 0) then

        if args.mainId == protodefine.main_login then

        else
            skynet.error("Invalid MainId", args.mainId, args.subId)
        end

    else
        skynet.error("Invalid Client Data", args)
    end

end

skynet.start(function()
    -- socket 命令
    skynet.dispatch("lua", socket_dispatch)

    -- 收到客服端的信息
    skynet.dispatch("client", client_dispatch)
end)

