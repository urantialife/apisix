local core = require("apisix.core")
local plugin_name = "key-auth"
local ipairs = ipairs


-- You can follow this document to write schema:
-- https://github.com/Tencent/rapidjson/blob/master/bin/draft-04/schema
-- rapidjson not supported `format` in draft-04 yet
local schema = {
    type = "object",
    properties = {
        key = {type = "string"},
    }
}


local _M = {
    version = 0.1,
    priority = 2500,
    name = plugin_name,
    schema = schema,
}


local create_consume_cache
do
    local consumer_ids = {}

    function create_consume_cache(consumers)
        core.table.clear(consumer_ids)

        for _, consumer in ipairs(consumers.nodes) do
            consumer_ids[consumer.conf.key] = consumer.consumer_id
        end

        return consumer_ids
    end

end -- do


function _M.check_schema(conf)
    local ok, err = core.schema.check(schema, conf)

    if not ok then
        return false, err
    end

    return true
end


function _M.rewrite(conf, ctx)
    local key = core.request.header(ctx, "apikey")
    if not key then
        return 401, {message = "Missing API key found in request"}
    end

    local consumer_conf = core.consumer.plugin(plugin_name)
    local consumers = core.lrucache.plugin(plugin_name, "consumers_key",
            consumer_conf.conf_version,
            create_consume_cache, consumer_conf)

    local consumer_id = consumers[key]
    if not consumer_id then
        return 401, {message = "Invalid API key in request"}
    end

    -- ctx.consumer_id = consumer_id
    core.log.info("hit key-auth access")
end


return _M
