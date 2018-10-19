local skynet = require "skynet"
local bsonlib = require "bson"
local mongo = require "skynet.db.mongo"
require "skynet.manager"

local db_client
local db
local CMD = {}

function CMD.init()

    local host = tostring(skynet.getenv("mongodb_ip"))
    local port = math.tointeger(skynet.getenv("mongodb_port"))
    local db_name = tostring(skynet.getenv("mongodb_dbname"))
    --local username = tostring(skynet.getenv("mongodb_auth"))
    --local password = tostring(skynet.getenv("mongodb_pwd"))

    local conf = { host = host, port = port, authdb = db_name }
    db_client = mongo.client(conf)
    db_client:getDB(db_name)
    db = db_client[db_name]

    skynet.error("connect mongodb succ")


end

function CMD.findOne(cname, selector, field_selector)
    return db[cname]:findOne(selector, field_selector)
end

function CMD.find(cname, selector, field_selector)
    return db[cname]:find(selector, field_selector)
end

function CMD.update(cname, ...)
    local collection = db[cname]
    collection:update(...)
    local r = db:runCommand("getLastError")
    if r.err ~= bsonlib.null then
        return false, r.err
    end

    if r.n <= 0 then
        skynet.error("mongodb update " .. cname .. " failed")
    end

    return ok, r.err
end

local ops = { 'insert', 'batch_insert', 'delete' }
for _, v in ipairs(ops) do
    CMD[v] = function(self, cname, ...)
        local c = db[cname]
        c[v](c, ...)
        local r = db:runCommand('getLastError')
        local ok = r and r.ok == 1 and r.err == Bson.null
        if not ok then
            skynet.error(v .. " failed: ", r.err, tname, ...)
        end
        return ok, r.err
    end
end

skynet.start(function()

    skynet.dispatch("lua", function(session, addr, command, ...)

        local f = CMD[command]
        assert(f, "Invalid command")

        local ok, ret = pcall(f, ...)
        if ok then
            skynet.ret(skynet.pcak(ret))
        end
    end)

    skynet.register("mongodb")

    CMD.init()

end)
