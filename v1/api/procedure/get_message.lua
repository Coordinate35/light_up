local helper = loadfile(ngx.var.root .. "/v1/helpers/global_helper.lua")()
local const = loadfile(ngx.var.root .. "/v1/constants/constants.lua")()
local http_response = loadfile(ngx.var.root .. "/v1/helpers/http_response.lua")()
local json = require("cjson")

ngx.req.read_body()
local args, err = ngx.req.get_post_args()
local form_check = loadfile(ngx.var.root .. "/v1/helpers/form_check.lua")()
local check_content = {"user_id", "access_token"}

if not form_check.check_form(args, check_content) then
	http_response.response_bad_request()
end

local user_id = helper.to_object_id(args.user_id)
if not helper.is_logined(user_id, args.access_token) then 
	http_response.response_not_logined()
end

local conn = loadfile(ngx.var.root .. "/v1/helpers/mongo_connect.lua")()
local db = conn:new_db_handle(ngx.var.db_name)
local get_message_log_collection = db:get_col("get_message_log")
local light_log_collection = db:get_col("light_log")
local user_collection = db:get_col("user")
local get_message_time = ngx.time()

local request_cursor = get_message_log_collection:find({
		["user_id"] = user_id
	}
)
if nil == request_cursor then
	http_response.response_server_error()
end

local sorted_request = request_cursor:sort({
		["time"] = -1
	}
)

local last_query_time

if nil == sorted_request[1] then 
	last_query_time = 0
else
	last_query_time = sorted_request[1]["time"]
end

local logs_cursor = light_log_collection:find({
		["target_id"] = user_id,
		["time"] = {
			["$gt"] = last_query_time
		},
		["available"] = true,
		["order"] = tostring(const.procedure_number)
	}
)

if nil == logs_cursor then
	http_response.response_server_error()
end

local logs = {}

for key, value in logs_cursor:pairs() do
	local user = user_collection:find_one({
			["_id"] = value.user_id,
			["available"] = true
		}, {
			["portrait"] = 1,
			["nickname"] = 1
		}
	)
	if nil == user then
		http_response.response_server_error()
	end
	value._id = value._id:tostring()
	user.user_id = user._id:tostring()
	user._id = nil
	user.portrait = "http://" .. const.upyun_domain .. user.portrait
	value.lighter = user
	value.content = "我为你亮了三盏灯，快来联系我吧～"
	value.order = nil
	value._id = nil
	value.available = nil
	value.user_id = nil
	value.target_id = nil
	table.insert(logs, value)
end

-- local n, err = get_message_log_collection:insert({
-- 		{
-- 			["user_id"] = user_id,
-- 			["time"] = ngx.time()
-- 		}
-- 	}
-- )
-- if nil == n then
-- 	print(err)
-- 	http_response.response_server_error()
-- end

local response = {
	["data"] = {
		["logs"] = logs
	}
}
json.encode_empty_table_as_object(false)
http_response.response_success(json.encode(response))