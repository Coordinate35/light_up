-- print(loadfile(ngx.var.root .. "/helpers/global_helper.lua"))
-- ngx.exit(ngx.HTTP_OK)
local helper = loadfile(ngx.var.root .. "/v1/helpers/global_helper.lua")()
local const = loadfile(ngx.var.root .. "/v1/constants/constants.lua")()
local http_response = loadfile(ngx.var.root .. "/v1/helpers/http_response.lua")()
dofile(ngx.var.root .. "/v1/helpers/table_util.lua")
local json = require("cjson")

local function check_form(phone_number)
	local form_check = loadfile(ngx.var.root .. "/v1/helpers/form_check.lua")()
	if not form_check.phone_number(phone_number) then
		return false
	end
	-- if not form_check.password(password) then
	-- 	return false
	-- end
	return true;
end

ngx.req.read_body()
local args, err = ngx.req.get_post_args()

local phone_number = args.phone_number
-- local password = args.password

-- print(phone_number)
if not check_form(phone_number) then
	http_response.response_bad_request()
end

local validate_code = helper.generate_validate_code()

local conn = loadfile(ngx.var.root .. "/v1/helpers/mongo_connect.lua")()
local db = conn:new_db_handle(ngx.var.db_name)
local user_collection = db:get_col("user")
local user = user_collection:find_one({
	["phone_number"] = phone_number,
	["available"] = true
})

if user then
	http_response.response_has_user()
end

local salt = helper.generate_salt()
user = {
	-- ["_id"] = helper.new_object_id(),
	["portrait"] = "",
	["phone_number"] = phone_number,
	["salt"] = salt,
	-- ["password"] = helper.crypt(password, salt),
	["password"] = "",
	["access_token"] = "",
	["device_token"] = "",
	["nickname"] = "",
	["weibo_nickname"] = "",
	["wechat_nickname"] = "",
	["weibo_uid"] = "",
	["wechat_uid"] = "",
    ["wechat_ID"] = "",
	["sex"] = "",
	["love_sex"] = "",
	["birthday"] = "",
	["location"] = "",
	["register_verified"] = false,
	["change_password_verified"] = false,
	["signin_ip"] = "",
	["signup_ip"] = "",
	["signin_time"] = "",
	["signup_time"] = ngx.time(),
	["validate_code"] = validate_code,
	["available"] = false
}
local n, err = user_collection:update({
		["phone_number"] = phone_number
	},
	user, 1, 0 ,1)
if not n then
	print("failed to insert db:", err)
	http_response.response_server_error()
end
print("new user inserted")

-- local new_user_id = user_collection:find_one({
-- 		["phone_number"] = phone_number
-- 	}, {
-- 		["_id"] = 1
-- 	}
-- )

-- new_user_id = new_user_id._id:tostring();

local response = {}
helper.send_validate_code(phone_number, validate_code)
response.status = "new a user, sms sent successfully";
response.data = {}
http_response.response_success(json.encode(response))
