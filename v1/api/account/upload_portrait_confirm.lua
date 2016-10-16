local helper = loadfile(ngx.var.root .. "/v1/helpers/global_helper.lua")()
local const = loadfile(ngx.var.root .. "/v1/constants/constants.lua")()
local http_response = loadfile(ngx.var.root .. "/v1/helpers/http_response.lua")()
local json = require("cjson")
dofile(ngx.var.root .. "/v1/helpers/table_util.lua")

ngx.req.read_body()
local args, err = ngx.req.get_post_args()
local form_check = loadfile(ngx.var.root .. "/v1/helpers/form_check.lua")()
local check_content = {"user_id", "access_token"}

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
local user_cullection = db:get_col("user")

local buffer = buffer_collection:find_one({
		["user_id"] = args.user_id
	}
)

if nil == buffer then 
	http_response.response_server_error()
elseif 0 == buffer then 
	http_response.no_such_request()
end

local n, err = user_cullection:update({
		["_id"] = args.user_id
	}, {
		["$set"] = {
			["portrait"] = buffer.save_key
		}
	}, 0, 0, 1
)

if not n then 
	http_response.response_server_error()
end

n, err = buffer_collection:delete({
		["user_id"] = args.user_id
	}
)

local response = {
	["status"] = "update portrait successfully",
	["data"] = {}
}
http_response.response_success(json.encode(response))