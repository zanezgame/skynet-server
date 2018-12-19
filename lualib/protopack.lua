local skynet = require "skynet"

local M = {}

function M.sub_pack(name, packet)
    return skynet.call("pbc", "lua", "encode", name, packet)

end

function M.main_pack(packet)
    return skynet.call("pbc", "lua", "encode", "Game.ProtoInfo", packet)

end

function M.main_unpack(packet)
    return skynet.call("pbc", "lua", "decode", "Game.ProtoInfo", packet)

end

function M.sub_unpack(name, packet)
    return skynet.call("pbc", "lua", "decode", name, packet)
end

return M
