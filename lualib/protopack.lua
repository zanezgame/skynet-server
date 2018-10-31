local skynet = require "skynet"

local M = {}

function M.sub_pack(name, data)
    return skynet.call("pbc", "lua", "encode", name, data)

end

function M.main_pack(data)
    return skynet.call("pbc", "lua", "encode", "Game.ProtoInfo", data)

end

function M.main_unpack(data)
    return skynet.call("pbc", "lua", "decode", "Game.ProtoInfo", data)

end

function M.sub_unpack(name, data)
    return skynet.call("pbc", "lua", "decode", name, data)
end

return M
