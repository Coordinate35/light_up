local helper = loadfile(ngx.var.root .. "/v1/helpers/global_helper.lua")()
local const = loadfile(ngx.var.root .. "/v1/constants/constants.lua")()
local http_response = loadfile(ngx.var.root .. "/v1/helpers/http_response.lua")()
local json = require("cjson")
dofile(ngx.var.root .. "/v1/helpers/table_util.lua")

ngx.req.read_body()
local args, err = ngx.req.get_post_args()
local form_check = loadfile(ngx.var.root .. "/v1/helpers/form_check.lua")()
local check_content = {
	"device_token"
}

if not form_check.check_form(args, check_content) then
	http_response.response_bad_request()
end

if nil ~= args.user_id then
	args.user_id = helper.to_object_id(args.user_id)
	if not helper.is_logined(args.user_id, args.access_token) then 
		http_response.response_not_logined()
	end
end

if not args.user_id then 
	args.user_id = ""
end
local conn = loadfile(ngx.var.root .. "/v1/helpers/mongo_connect.lua")()
local db = conn:new_db_handle(ngx.var.db_name)
local device_token_collection = db:get_col("device_token")

local n, err = device_token_collection:insert({{
		["user_id"] = args.user_id,
		["device_token"] = args.device_token,
		["create_time"] = ngx.time()
	}}
)
if not n then 	
	print(err)
	http_response.response_server_error()	
end

local response = {
	["status"] = "update device_token successfully",
	["data"] = {}
}
http_response.response_success(json.encode(response))