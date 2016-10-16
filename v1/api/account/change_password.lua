local helper = loadfile(ngx.var.root .. "/v1/helpers/global_helper.lua")()
local http_response = loadfile(ngx.var.root .. "/v1/helpers/http_response.lua")()
dofile(ngx.var.root .. "/v1/helpers/table_util.lua")
local json = require("cjson")

local function check_form(phone_number, password)
	local form_check = loadfile(ngx.var.root .. "/v1/helpers/form_check.lua")()
	if not form_check.phone_number(phone_number) then
		return false
	end
	if not form_check.password(password) then
		return false
	end
	return true;
end

ngx.req.read_body()
local args, err = ngx.req.get_post_args()

local phone_number = args.phone_number
local password = args.password

if not check_form(phone_number, password) then
	http_response.response_bad_request()
end


local salt = helper.generate_salt()
local conn = loadfile(ngx.var.root .. "/v1/helpers/mongo_connect.lua")()
local db = conn:new_db_handle(ngx.var.db_name)
local user_collection = db:get_col("user")
local n, err = user_collection:update({
		["phone_number"] = phone_number,
		["change_password_verified"] = true
	}, {
		["$set"] = {
			["change_password_verified"] = false,
			["password"] = helper.crypt(password, salt),
			-- ["available"] = true,
			["salt"] = salt
		}
	}, 0, 0 ,1
)

if n == nil then
	http_response.response_server_error()
	print(n, err)
elseif n == 0 then
	http_response.response_sms_not_verified()
end

local response = {}
response.status = "change password successfully"
response.data = {}
http_response.response_success(json.encode(response))
