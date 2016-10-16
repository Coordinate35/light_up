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
if not helper.is_refreshable(args.user_id, args.access_token) then
	http_response.response_not_logined()
end

local access_token = helper.generate_salt()

local conn = loadfile(ngx.var.root .. "/v1/helpers/mongo_connect.lua")()
local db = conn:new_db_handle(ngx.var.db_name)
local user_collection = db:get_col("user")
local n, err = user_collection:update({
		["_id"] = args.user_id
	}, {
		["$set"] = {
			["access_token"] = access_token,
			["signin_time"] = ngx.time()
		}
	}, 0, 0, 1
)

if not n then 
	print(n, err)
	http_response.response_server_error()
end

local response = {["data"] = {}}
response.data["access_token"] = access_token
http_response.response_success(json.encode(response))

