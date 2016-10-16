local json = require("cjson")
-- print(loadfile(ngx.var.root .. "/v1/helpers/global_helper.lua"))
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
	"target_id",
	"class",
	"file_type"
}

if not form_check.check_form(args, check_content) then
	http_response.response_bad_request()
end

args.user_id = helper.to_object_id(args.user_id)
-- if not helper.is_logined(args.user_id, args.access_token) then 
-- 	http_response.response_not_logined()
-- end

args.target_id = helper.to_object_id(args.target_id)
local conn = loadfile(ngx.var.root .. "/v1/helpers/mongo_connect.lua")()
local db = conn:new_db_handle(ngx.var.db_name)
local media_collection = db:get_col(args.file_type)

local media = media_collection:find_one({
		["owner_id"] = args.target_id,
		["class"] = args.class,
		["available"] = true
	}
)

if nil == media then 
	http_response.response_server_error()
elseif 0 == media then
	http_response.no_such_media()
end
if "audio" == args.file_type then 
	local response = {["data"] = {}}
	for key, value in pairs(media.question_arr) do 
		media.question_arr[key].question_content = helper.get_question_by_id(value.question_id, args.class)
		media.question_arr[key].save_key = "http://" .. const.upyun_domain .. media.question_arr[key].save_key
	end
	response.data["questions"] = media.question_arr
	http_response.response_success(json.encode(response))
elseif "video" == args.file_type then
	local response = {["data"] = {}}
	response["data"].save_key = "http://" .. const.upyun_domain .. media.save_key
	response["data"].questions = media.questions
	for key, value in pairs(media.questions) do
		response["data"].questions[key].question_content = helper.get_question_by_id(value.question_id, args.class)
	end
	http_response.response_success(json.encode(response))
end
