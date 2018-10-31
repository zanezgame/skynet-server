local skynet = require "skynet"
local protopack = require "protopack"
local websocket = require "websocket"

local CMD = {}
local SOCKET = {}

local gate
local agent = {}

function SOCKET.open(fd, addr)
    skynet.error("new websocket client from : " .. addr)
    skynet.call(gate, "lua", "accept", fd)
end

local function close_agent(fd)
    local a = agent[fd]
    agent[fd] = nil
    if a then
        skynet.call(gate, "lua", "kick", fd)
        -- disconnect never return
        skynet.send(a, "lua", "disconnect")
    end
end

function SOCKET.close(fd)
    print("websocket close", fd)
    close_agent(fd)
end

function SOCKET.error(fd, msg)
    print("websocket error", fd, msg)
    close_agent(fd)
end

function SOCKET.warning(fd, size)
    -- size K bytes havn't send out in fd
    print("websocket warning", fd, size)
end

function SOCKET.data(fd, data)


    local args = protopack.main_unpack(data)
    --测试代码
    if (args ~= false and args.mainId ~= nil and args.mainId > 0) then
        skynet.error(args.mainId, args.subId)

        local ldata1 = protopack.sub_pack("Login.s2c_login", { account = "1111", token = "okokok" })

        local ldata2 = protopack.main_pack({ mainId = 100, subId = 1, body = ldata1 });

        websocket:send_binary(fd, ldata2)
    end


end

function CMD.start(conf)
    skynet.call(gate, "lua", "open", conf)
end

function CMD.close(fd)
    close_agent(fd)
end

local start_agent = function(fd)

    agent[fd] = skynet.newservice("agent")
    local conf = { gate = gate, client = fd, watchdog = skynet.self(), socket_type = 1 }
    skynet.call(agent[fd], "lua", "start", conf)
end

local dispatch = function(session, source, cmd, subcmd, ...)

    if cmd == "socket" then
        local f = SOCKET[subcmd]
        f(...)
        -- socket api don't need return
    else
        local f = assert(CMD[cmd])
        skynet.ret(skynet.pack(f(subcmd, ...)))
    end
end

skynet.start(function()

    skynet.dispatch("lua", dispatch)

    gate = skynet.newservice("wsgate")
end)
