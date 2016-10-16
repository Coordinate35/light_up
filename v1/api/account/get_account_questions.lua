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
	"class"
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
local user_collection = db:get_col("user")
local user = user_collection:find_one({
		["_id"] = args.user_id,
		["available"] = true
	}
)
if nil == user then
	http_response.response_server_error()
end
local response = {
	["data"] = {}
}
print(user.nickname)
response.data["questions"] = user.questions[args.class]
http_response.response_success(json.encode(response))