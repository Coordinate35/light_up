local helper = loadfile(ngx.var.root .. "/v1/helpers/global_helper.lua")()
local http_response = loadfile(ngx.var.root .. "/v1/helpers/http_response.lua")()
local const = loadfile(ngx.var.root .. "/v1/constants/constants.lua")()
dofile(ngx.var.root .. "/v1/helpers/table_util.lua")
local json = require("cjson")

ngx.req.read_body()
local check_content = {}
local args, err = ngx.req.get_post_args()
local form_check = loadfile(ngx.var.root .. "/v1/helpers/form_check.lua")()

check_content = {
	"user_id",
	"access_token",
	"file_type",
	"class"
}

if not form_check.check_form(args, check_content) then
	http_response.response_bad_request()
end

if not helper.is_logined(helper.to_object_id(args.user_id), args.access_token) then
	http_response.response_not_logined()
end

args.user_id = helper.to_object_id(args.user_id)
local conn = loadfile(ngx.var.root .. "/v1/helpers/mongo_connect.lua")()
local db = conn:new_db_handle(ngx.var.db_name)
local formal_collection = db:get_col(args.file_type)

local n, err = formal_collection:update({
		["owner_id"] = args.user_id,
		["class"] = args.class
	}, {
		["$set"] = {
			["available"] = false
		}
	}, 0, 1, 1
)

if nil ==  n then 
	http_response.response_bad_request()
end

local response = {}
response.status = "operate successfully"
response.data = {}
http_response.response_success(json.encode(response))

