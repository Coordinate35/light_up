local helper = loadfile(ngx.var.root .. "/v1/helpers/global_helper.lua")()
local http_response = loadfile(ngx.var.root .. "/v1/helpers/http_response.lua")()
local json = require("cjson")
dofile(ngx.var.root .. "/v1/helpers/table_util.lua")

local function check_form(phone_number, validate_code, validate_type)
	local form_check = loadfile(ngx.var.root .. "/v1/helpers/form_check.lua")()
	if (not form_check.phone_number(phone_number)) then
		return false
	end
	if not form_check.validate_code(validate_code) then
		return false
	end
	if not form_check.validate_type(validate_type) then
		return false
	end
	return true
end

ngx.req.read_body()

local args, err = ngx.req.get_post_args()

local phone_number = args.phone_number
local validate_code = args.validate_code
local validate_type = args.validate_type

if not check_form(phone_number, validate_code, validate_type) then
	http_response.response_bad_request()
end

local conn = loadfile(ngx.var.root .. "/v1/helpers/mongo_connect.lua")()
local db = conn:new_db_handle(ngx.var.db_name)
local user_collection = db:get_col("user")
local user = user_collection:find_one({
	["phone_number"] = phone_number
})

if not user then
	http_response.response_server_error()
end

local key = {}
if "register" == validate_type then
	key = "register_verified"
elseif "change_password" == validate_type then 
	key = "change_password_verified"
else
	http_response.response_server_error()
end

-- r = user_collection:find_one({['phone_number'] = phone_number})
-- print(table.tostring(r))

if math.floor(tonumber(user.validate_code)) ~= math.floor(tonumber(validate_code))  then
	http_response.response_validate_code_not_right()
end

local access_token = helper.generate_salt()
local n, err = user_collection:update({
		["phone_number"] = phone_number
	}, {
		["$set"] = {
			[key] = true,
			["signin_time"] = ngx.time(),
			["access_token"] = access_token,
			["validate_code"] = -1
		}
	}, 1
)

if n == nil then
	print(n, err)
	http_response.response_server_error()
end

if "register" == validate_type then
	local n, err = user_collection:update({
			["phone_number"] = phone_number
		}, {
			["$set"] = {
				["change_password_verified"] = true
			}
		}, 1
	)
	if n == nil then
		print(n, err)
		http_response.response_server_error()
	end
end

local response = {["data"] = {}}
response.data["user_id"] = user._id:tostring()
response.data["access_token"] = access_token
http_response.response_success(json.encode(response))