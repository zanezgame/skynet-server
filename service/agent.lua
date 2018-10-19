local skynet = require "skynet"

local watchdog

local CMD = {}

local client_fd

skynet.register_protocol {
    name = "client",
    id = skynet.PTYPE_CLIENT,
    unpack = skynet.tostring,
}

function CMD.start(conf)
    local fd = conf.client
    local gate = conf.gate
    watchdog = conf.watchdog

    client_fd = fd
    skynet.call(gate, "lua", "forward", fd)
end

function CMD.disconnect()
    -- todo: do something before exit
    skynet.exit()
end

skynet.start(function()

    -- socket 命令
    skynet.dispatch("lua", function(_, _, command, ...)

        skynet.error(command)

        local f = CMD[command]

        assert(f, "Invalid command")

        skynet.ret(skynet.pack(f(...)))
    end)

    -- 收到客服端的信息
    skynet.dispatch("client", function(_, _, msg)

        --todo: client msg

        skynet.error("client===>", msg)
    end)
end)

