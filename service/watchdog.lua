local skynet = require("skynet")

local CMD = {}
local SOCKET = {}
local gate
local agent = {}

function SOCKET.open(fd, addr)
    skynet.error("new tcp socket client from : " .. addr)
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
    print("tcp socket close", fd)
    close_agent(fd)
end

function SOCKET.error(fd, msg)
    print("tcp socket error", fd, msg)
    close_agent(fd)
end

function SOCKET.warning(fd, size)
    -- size K bytes havn't send out in fd
    print("tcp socket warning", fd, size)
end

function SOCKET.data(fd, msg)
    skynet.error("SOCKET.data", fd, msg)
end

function CMD.start(conf)
    skynet.call(gate, "lua", "open", conf)
end

function CMD.close(fd)
    close_agent(fd)
end

local start_agent = function(fd)

    agent[fd] = skynet.newservice("agent")
    local conf = { gate = gate, client = fd, watchdog = skynet.self(), socket_type = 0 }
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

    gate = skynet.newservice("gate")
end)
