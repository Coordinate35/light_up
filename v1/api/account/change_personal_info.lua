local helper = loadfile(ngx.var.root .. "/v1/helpers/global_helper.lua")()
local const = loadfile(ngx.var.root .. "/v1/constants/constants.lua")()
local http_response = loadfile(ngx.var.root .. "/v1/helpers/http_response.lua")()
dofile(ngx.var.root .. "/v1/helpers/table_util.lua")
local json = require("cjson")

ngx.req.read_body()
local args, err = ngx.req.get_post_args()
local form_check = loadfile(ngx.var.root .. "/v1/helpers/form_check.lua")()
local check_content = {"user_id", "access_token", "personal_info"}
if not form_check.check_form(args, check_content) then
	http_response.response_bad_request()
end

local _id = helper.to_object_id(args.user_id)
local access_token = args.access_token
local personal_info = json.decode(args.personal_info)
if not helper.is_personal_info_changeable(_id, access_token) then 
	http_response.response_not_logined()
end

-- personal_info.access_token = helper.generate_salt()

local conn = loadfile(ngx.var.root .. "/v1/helpers/mongo_connect.lua")()
local db = conn:new_db_handle(ngx.var.db_name)
local user_collection = db:get_col("user")
local user = user_collection:find_one({
	["_id"] = _id
	-- ["available"] = true
})

if user == nil then
	http_response.response_no_such_user(phone_number)
end
if 0 ~= #user.sex then
	personal_info.sex = nil
end

if nil ~= personal_info.nickname then
	same_nickname_user = user_collection:find_one({
			["nickname"] = personal_info.nickname,
		}
	)
	if nil ~= same_nickname_user then 
		if same_nickname_user._id ~= _id then
			http_response.response_nickname_has_been_used()
		end
	end
end

personal_info.available = true
local conn = loadfile(ngx.var.root .. "/v1/helpers/mongo_connect.lua")()
local db = conn:new_db_handle(ngx.var.db_name)
local user_collection = db:get_col("user")
local n, err = user_collection:update({
		["_id"] = _id
	}, {
		["$set"] = personal_info
	}, 1
)

if not n then 
	print(n, err)
	http_response.response_server_error()
end

local response = {}
response.data = "change personal_info successfully"
http_response.response_success(json.encode(response))