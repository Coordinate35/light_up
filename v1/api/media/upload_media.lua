local helper = loadfile(ngx.var.root .. "/v1/helpers/global_helper.lua")()
local http_response = loadfile(ngx.var.root .. "/v1/helpers/http_response.lua")()
local upyun = loadfile(ngx.var.root .. "/v1/helpers/upyun.lua")()
local const = loadfile(ngx.var.root .. "/v1/constants/constants.lua")()
dofile(ngx.var.root .. "/v1/helpers/table_util.lua")
local json = require("cjson")

ngx.req.read_body()
local check_content = {}
local args, err = ngx.req.get_post_args()
local form_check = loadfile(ngx.var.root .. "/v1/helpers/form_check.lua")

if "audio" == args.file_type then 
	check_content = {
		"user_id", 
		"access_token",
		"sex",
		"audio_class",
		"question_arr"
	}
elseif "video" == args.file_type then
	check_content = {
		"user_id", 
		"access_token",
		"sex",
		"video_class",
		"save_key",
		"questions"
	}
else
	http_response.response_bad_request()
end

local form_check = loadfile(ngx.var.root .. "/v1/helpers/form_check.lua")()
if not form_check.check_form(args, check_content) then
	http_response.response_bad_request()
end

if not helper.is_logined(helper.to_object_id(args.user_id), args.access_token) then
	http_response.response_not_logined()
end

local bucket
local expiration = ngx.time() + 86400
local conn = loadfile(ngx.var.root .. "/v1/helpers/mongo_connect.lua")()
local db = conn:new_db_handle(ngx.var.db_name)
local formal_collection = db:get_col(args.file_type)
local standard = {}
if "audio" == args.file_type then
	standard.owner_id = helper.to_object_id(args.user_id)
	standard.sex = args.sex
	standard.question_arr = json.decode(args.question_arr)
	standard.class = args[args.file_type .. "_class"]
	bucket = const.upyun_audio_bucket
elseif "video" == args.file_type then
	standard.owner_id = helper.to_object_id(args.user_id)
	standard.sex = args.sex
	standard.save_key = args.save_key
	standard.questions = json.decode(args.questions)
	standard.class = args[args.file_type .. "_class"]
	bucket = const.upyun_video_bucket
end
standard.time = ngx.time()
standard.available = true

local n, err = formal_collection:update({
		["owner_id"] = standard.owner_id,
		["class"] = standard.class
	}, {
		["$set"] = {
			["available"] = false
		}
	}, 0, 0, 1
)

if nil ==  n then 
	http_response.response_bad_request()
end

local n, err = formal_collection:insert({
		standard
	}
)

if not n then
	print(n, err)
	http_response.response_server_error()
end

local response = {}
response.status = "set upload file successfully"
response.data = {}

http_response.response_success(json.encode(response))