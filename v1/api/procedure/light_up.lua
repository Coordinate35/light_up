local json = require("cjson")
local helper = loadfile(ngx.var.root .. "/v1/helpers/global_helper.lua")()
local const = loadfile(ngx.var.root .. "/v1/constants/constants.lua")()
local random = require("resty.random")
local http_response = loadfile(ngx.var.root .. "/v1/helpers/http_response.lua")()
dofile(ngx.var.root .. "/v1/helpers/table_util.lua")

ngx.req.read_body()
local args, err = ngx.req.get_post_args()
args.light_status = math.floor(tonumber(args.light_status))
local form_check = loadfile(ngx.var.root .. "/v1/helpers/form_check.lua")()
local check_content = {
	"user_id", 
	"access_token",
	"target_id",
	"order",
	"light_status"
}

if not form_check.check_form(args, check_content) then
	http_response.response_bad_request()
end

local available
args.user_id = helper.to_object_id(args.user_id)
args.target_id = helper.to_object_id(args.target_id)
if 0 == args.light_status then
	available = false
end
if 1 == args.light_status then
	available = true
end
-- if not helper.is_logined(args.user_id, args.access_token) then 
-- 	http_response.response_not_logined()
-- end

local conn = loadfile(ngx.var.root .. "/v1/helpers/mongo_connect.lua")()
local db = conn:new_db_handle(ngx.var.db_name)
local light_log_collection = db:get_col("light_log")
local video_collection = db:get_col("video");
local is_information_complete

local n = video_collection:count({
		["owner_id"] = args.user_id,
		["class"] = "value_concept",
		["available"] = true
	}
)
if (nil == n) then
	http_response.response_server_error()
elseif (0 == n) then
	is_information_complete = false
else
	is_information_complete = true
end

if (false == is_information_complete) then
	local time_table = os.date("*t")
	local year = time_table.year
	local month = time_table.month
	local day = time_table.day
	local today_timestamp = os.time{year=year, month=month, day=day} - const.half_day_second
	n = light_log_collection:count({
			["user_id"] = args.user_id,
			["available"] = true,
			["time"] = {
				["$gt"] = today_timestamp
			}
		}
	)
	if (nil == n) then
		http_response.response_server_error()
	end
	if (n >= const.light_up_uplimit_for_uncomplete_user) then 
		http_response.response_light_number_uplimit()
	end
end

local n, err = light_log_collection:update({
		["user_id"] = args.user_id,
		["target_id"] = args.target_id,
		["order"] = args.order
	}, {
		["$set"] = {
			["available"] = false
		}
	}, 0, 1, 1
) 
if not n then
	print(err)
	http_response.response_server_error()
end
print(n)

local n, err = light_log_collection:insert({{
		["user_id"] = args.user_id,
		["target_id"] = args.target_id,
		["order"] = args.order,
		["time"] = ngx.time(),
		["available"] = available
	}}
)

if not n then
	print(err)
	http_response.response_server_error()
end

local response = { ["data"] = {}}
response["status"] = "light up successfully"


if const.last_light_order == args.order and 1 == args.light_status then
	local redis = require("resty.redis")
	local red = redis:new()
	red:set_timeout(1000)
	local ok, err = red:connect("127.0.0.1", 6379)
	if not ok then 
		print("redis: " .. err)
	end
	local message = {}
	message.user_id = args.user_id:tostring()
	message.target_id = args.target_id:tostring()
	message = json.encode(message)
	local res, err = red:publish("light_last_light", message)
	if not res then
	    print("redis: failed to publish, ", err)
	end
end
http_response.response_success(json.encode(response))