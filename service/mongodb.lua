local skynet = require "skynet"
local mongo = require "skynet.db.mongo"
require "skynet.manager"

local db_client
local db = nil
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

end

---@param selector ：可选，使用查询操作符指定查询条件
---@param field_selector ：可选，使用投影操作符指定返回的键。查询时返回文档中所有键值， 只需省略该参数即可（默认省略）。

function CMD.findOne(cname, selector, field_selector)
    return db[cname]:findOne(selector, field_selector)
end

---@param selector ：可选，使用查询操作符指定查询条件
---@param field_selector ：可选，使用投影操作符指定返回的键。查询时返回文档中所有键值， 只需省略该参数即可（默认省略）。

function CMD.find(cname, selector, field_selector)
    local cursor = db[cname]:find(selector, field_selector)

    if cursor:hasNext() then
        local results = {};
        local count = cursor:count()
        for i = 1, count, 1 do
            table.insert(results, cursor:next())
        end
        return results
    else
        return nil
    end
end

function CMD.insert(cname, doc)
    return db[cname]:safe_insert(doc)
end

---@param selector :（可选）删除的文档的条件。
---@param single : （可选）如果设为 true 或 1，则只删除一个文档
function CMD.delete(cname, selector, single)
    return db[cname]:safe_delete(selector, single)
end

---@param query : update的查询条件，类似sql update查询内where后面的。
---@param update : update的对象和一些更新的操作符（如$,$inc...）等，也可以理解为sql update查询内set后面的
---@param upsert : 可选，这个参数的意思是，如果不存在update的记录，是否插入objNew,true为插入，默认是false，不插入。
---@param multi : 可选，mongodb 默认是false,只更新找到的第一条记录，如果这个参数为true,就把按条件查出来多条记录全部更新。

function CMD.update(cname, selector, update, upsert, multi)
    return db[cname]:safe_update(selector, update, upsert, multi)
end

local dispatch = function(session, addr, command, ...)
    local f = CMD[command]
    assert(f, "Invalid command")
    local ok, ret = pcall(f, ...)
    skynet.ret(skynet.pack(ret))
end

skynet.start(function()

    skynet.dispatch("lua", dispatch)

    skynet.register("mongodb")

    CMD.init()

    --local data = skynet.call(skynet.self(), "lua", "update", "user", { user = 1 }, { ["$set"] = { user = 100, name = "zane1" } }, false, true)
    --local data = skynet.call(skynet.self(), "lua", "insert", "user", { user = 1000 })
    --skynet.error(data)

end)
