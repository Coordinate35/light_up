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
	"love_sex"
}

if not form_check.check_form(args, check_content) then
	http_response.response_bad_request()
end

args.user_id = helper.to_object_id(args.user_id)
if not helper.is_logined(args.user_id, args.access_token) then 
	http_response.response_not_logined()
end

local conn = loadfile(ngx.var.root .. "/v1/helpers/mongo_connect.lua")()
local db = conn:new_db_handle(ngx.var.db_name)

local time_table = os.date("*t")
local year = time_table.year
local month = time_table.month
local day = time_table.day
local hour = time_table.hour
local today_timestamp = os.time{year=year, month=month, day=day} - const.half_day_second
local timestamp = ngx.time() - today_timestamp
if hour >= const.nineteen_oclock then
	timestamp = timestamp - const.day_nineteen_oclock_second
	today_timestamp = today_timestamp + const.day_nineteen_oclock_second
else
	timestamp = timestamp + const.day_five_oclock_second 
	today_timestamp = today_timestamp - const.day_five_oclock_second
end
local in_segment = helper.get_segment(timestamp)
local have_seen_log_collection = db:get_col("have_seen_log")
local log = have_seen_log_collection:find({
		["user_id"] = args.user_id,
		["date"] = helper.get_today_name(today_timestamp),
		["segment"] = in_segment
	}
)

if not log then
	http_response.response_server_error()
end
local have_seen_guest_number 

if nil == log.target_ids then 
	log.target_ids = {}
	have_seen_guest_number = 0
else
	have_seen_guest_number = table.getn(log.target_ids)
end
if const.allow_get_user_number_a_segment <= have_seen_guest_number then
	http_response.response_segment_limit()
end


local today_have_seen_number = 0
local video_collection = db:get_col("video")
local complete = video_collection:count({
		["owner_id"] = args.user_id,
		["available"] = true,
		["class"] = "value_concept"
	}
)
if nil == complete then
	http_response.response_server_error()
end
if 0 == complete then
	local time_have_seen_log_collection = db:get_col("time_have_seen_log")
	local real_taday_timestamp = os.time{year=year, month=month, day=day} - const.half_day_second
	today_have_seen_number = have_seen_log_collection:count({
			["user_id"] = args.user_id,
			["time"] = {
				["$gt"] = real_taday_timestamp
			}
		}
	)
	if not today_have_seen_number then
		http_response.response_server_error()
	end
end
if const.allow_get_user_number_a_day_for_complete <= today_have_seen_number then
	http_response.response_day_allow_guest_number_uplimit_for_uncomplete()
end


local media_collection = db:get_col("video")
if "both" == args.love_sex then 
	args.love_sex = nil
end
local condition = {
	["available"] = true,
	["class"] = "value_concept",
	["sex"] = args.love_sex
}
local guests = media_collection:find(
	condition, {
		["owner_id"] = 1
	}, 500
)

if nil == guests then
	http_response.response_server_error()
elseif 0 == guests then
	http_response.response_no_guest()
end

local dealed_guests = {}
for key, value in guests:pairs() do
	dealed_guests[key] = value
end

local count = table.getn(dealed_guests)
if count <= have_seen_guest_number then 
	http_response.response_segment_limit()
end

if nil == dealed_guests then
	http_response.response_no_guest()
end

local have_found = false
local loop_time = 50
local target_id
local have_light_number
repeat
	local index = random.number(1, count)
	target_id = dealed_guests[index]["owner_id"]
	if false == helper.is_complete(db, dealed_guests[index]["owner_id"]) or helper.in_array(dealed_guests[index]["owner_id"], log.target_ids) or target_id == args.user_id then
		table.remove(dealed_guests, index)
		target_id = nil
	else
		local light_log_collection = db:get_col("light_log")
		have_light_number = light_log_collection:count({
				["available"] = true,
				["user_id"] = args.user_id,
				["target_id"] = target_id
			}
		)
		have_found = true
	end
	count = count - 1
	loop_time = loop_time - 1
until have_found == true or loop_time == 0 or count == 0
if target_id == nil then
	http_response.response_no_guest()
end

local response = {["data"] = {}}
response["data"]["target_id"] = target_id:tostring()
response["data"]["have_light_number"] = have_light_number
http_response.response_success(json.encode(response))
