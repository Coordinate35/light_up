-- ngx.req.read_body()
-- local h = ngx.resp.get_headers(0)
-- for k, v in pairs(h) do
-- 	ngx.say(k .. ' ' .. v)
-- end

-- local body = ngx.var.request_body
-- ngx.say(body)

-- local args, err = ngx.req.get_post_args()

-- local phone_number = args.phone_numbe

-- local arr = {"aaaa", "bbbb", "cccc"}

-- table.insert(arr, "dddd")

-- for key, value in ipairs(arr) do
-- 	print(key .. ' ' .. value)
-- end

local json = require "cjson"
t = 'd d['
print(json.decode(t))
