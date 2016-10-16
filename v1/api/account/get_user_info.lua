-- TODO:add light up number check

local helper = loadfile(ngx.var.root .. "/v1/helpers/global_helper.lua")()
local const = loadfile(ngx.var.root .. "/v1/constants/constants.lua")()
local http_response = loadfile(ngx.var.root .. "/v1/helpers/http_response.lua")()
local json = require("cjson")
dofile(ngx.var.root .. "/v1/helpers/table_util.lua")

ngx.req.read_body()
local args, err = ngx.req.get_post_args()
local form_check = loadfile(ngx.var.root .. "/v1/helpers/form_check.lua")()
local check_content = {"user_id", "access_token", "target_id"}

if not form_check.check_form(args, check_content) then
	http_response.response_bad_request()
end

args.user_id = helper.to_object_id(args.user_id)
-- if not helper.is_logined(args.user_id, args.access_token) then 
-- 	http_response.response_not_logined()
-- end



local conn = loadfile(ngx.var.root .. "/v1/helpers/mongo_connect.lua")()
local db = conn:new_db_handle(ngx.var.db_name)
local user_collection = db:get_col("user")
local target = user_collection:find_one({
		['_id'] = helper.to_object_id(args.target_id),
		['available'] = true
	}
)

if nil == target then
	http_response.response_server_error()
elseif 0 == target then
	http_response.response_no_such_user()
end

local response = {
	["data"] = {}
}
target.user_id = target._id:tostring()
target._id = nil
for key, value in ipairs(const.user_info_response) do
	response.data[value] = target[value]
end
if 0 ~= #tostring(response["data"].birthday) then
	response.data["age"] = helper.get_age(tostring(response.data["birthday"]))
else
	response.data["age"] = 0
end

for key, value in pairs(const.part) do
	local collection = db:get_col(value.media_type)
	local has = collection:count({
			["owner_id"] = helper.to_object_id(args.target_id),
			["available"] = true,
			["class"] = value.class
		}
	)
	if nil == has then
		http_response.response_server_error()
	end
	if 0 < has then
		response.data[value.class .. "_complete"] = true
	else
		response.data[value.class .. "_complete"] = false
	end
end

local light_log_collection = db:get_col("light_log")
response.data["basic_info_light_number"] = helper.get_light_number(light_log_collection, helper.to_object_id(args.target_id), "basic_info")
response.data["emotion_experience_light_number"] = helper.get_light_number(light_log_collection, helper.to_object_id(args.target_id), "emotion_experience")
response.data["value_concept_light_number"] = helper.get_light_number(light_log_collection, helper.to_object_id(args.target_id), "value_concept")

if 0 ~= #response.data['portrait'] then
	response.data['portrait'] = 'http://' .. const.upyun_domain .. '/' .. response.data['portrait']
end

http_response.response_success(json.encode(response))
