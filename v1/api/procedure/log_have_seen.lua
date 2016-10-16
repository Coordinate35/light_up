local json = require("cjson")
local helper = loadfile(ngx.var.root .. "/v1/helpers/global_helper.lua")()
local const = loadfile(ngx.var.root .. "/v1/constants/constants.lua")()
local random = require("resty.random")
local http_response = loadfile(ngx.var.root .. "/v1/helpers/http_response.lua")()
dofile(ngx.var.root .. "/v1/helpers/table_util.lua")

ngx.req.read_body()
local args, err = ngx.req.get_post_args()
local form_check = loadfile(ngx.var.root .. "/v1/helpers/form_check.lua")()
local check_content = {
	"user_id", 
	"access_token",
	"target_id"
}

if not form_check.check_form(args, check_content) then
	http_response.response_bad_request()
end

args.user_id = helper.to_object_id(args.user_id)
if not helper.is_logined(args.user_id, args.access_token) then 
	http_response.response_not_logined()
end

local time_table = os.date("*t")
local year = time_table.year
local month = time_table.month
local day = time_table.day
local hour = time_table.hour
local today_timestamp = os.time{year=year, month=month, day=day} - const.half_day_second
local timestamp = ngx.time() - today_timestamp
if hour >= const.nineteen_oclock then
	timestamp = timestmap - const.day_nineteen_oclock_second
	today_timestamp = today_timestamp + const.day_nineteen_oclock_second
else
	timestamp = timestamp + const.day_five_oclock_second 
	today_timestamp = today_timestamp - const.day_five_oclock_second
end
local in_segment = helper.get_segment(timestamp)
local conn = loadfile(ngx.var.root .. "/v1/helpers/mongo_connect.lua")()
local db = conn:new_db_handle(ngx.var.db_name)
local have_seen_log_collection = db:get_col("have_seen_log")
local time_have_seen_log_collection = db:get_col("time_have_seen_log")
local have_seen_log = have_seen_log_collection:find_one({
		["user_id"] = args.user_id,
		["date"] = helper.get_today_name(today_timestamp),
		["segment"] = in_segment
	}
)

if (nil == log) then
	have_seen_log = {}
	have_seen_log.user_id = args.user_id
	have_seen_log.date = helper.get_today_name(today_timestamp)
	have_seen_log.segment = in_segment
	have_seen_log.target_ids = {}
end

table.insert(have_seen_log.target_ids, args.target_id)

local n, err = have_seen_log_collection:update({
		["user_id"] = have_seen_log.user_id,
		["date"] = have_seen_log.date,
		["segment"] = have_seen_log.segment
	},
	have_seen_log, 1, 0 ,1
)

if nil == n then 
	print(err)
	http_response.response_server_error()
end

local n, err = time_have_seen_log_collection:insert(
	{
		{
			["user_id"] = args.user_id,
			["time"] = ngx.time(),
			["target_id"] = args.target_id
		}
	}
)
if nil == n then
	print(err)
	http_response.response_server_error()
end

local response = {}
response.status = "Accept"
response.data = {}
http_response.response_success(json.encode(response))