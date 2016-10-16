local helper = loadfile(ngx.var.root .. "/v1/helpers/global_helper.lua")()
local const = loadfile(ngx.var.root .. "/v1/constants/constants.lua")()
local http_response = loadfile(ngx.var.root .. "/v1/helpers/http_response.lua")()
local json = require("cjson")
dofile(ngx.var.root .. "/v1/helpers/table_util.lua")

ngx.req.read_body()
local args, err = ngx.req.get_post_args()
local form_check = loadfile(ngx.var.root .. "/v1/helpers/form_check.lua")()
local check_content = {"user_id", 
	"access_token",
	"save_key", 
	"bucket", 
	"expiration"
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
local buffer_collection = db:get_col("portrait_buffer")
local buffer = {}
buffer.user_id = args.user_id
buffer.save_key = args.save_key

local n, err = buffer_collection:update({
		["user_id"] = buffer.user_id
	}, {
		["$set"] = buffer
	}, 1, 0 ,1
)

if not n then 
	print(n, err)
	http_response.response_server_error()
end

local upyun = loadfile(ngx.var.root .. "/v1/helpers/upyun.lua")()
local policy = upyun.generate_policy(args.bucket, args.expiration, args.save_key)
local signature = upyun.generate_signature(policy, const.upyun_form_key)
local response = {["data"] = {}}
response.data["policy"] = policy
response.data["signatrue"] = signature
http_response.response_success(json.encode(response))