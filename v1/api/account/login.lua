local helper = loadfile(ngx.var.root .. "/v1/helpers/global_helper.lua")()
local const = loadfile(ngx.var.root .. "/v1/constants/constants.lua")()
local http_response = loadfile(ngx.var.root .. "/v1/helpers/http_response.lua")()
local json = require("cjson")
dofile(ngx.var.root .. "/v1/helpers/table_util.lua")

local function check_form(phone_number, password, login_type, access_token)
	local form_check = loadfile(ngx.var.root .. "/v1/helpers/form_check.lua")()
	if not form_check.login_type(login_type) then
		return false
	end
	if not form_check.phone_number(phone_number) then
		return false
	end
	if login_type == "password" then 
		if not form_check.password(password) then
			return false
		end
	elseif login_type == "access_token" then 
		if not form_check.access_token(access_token) then
			return false
		end
	end
	return true
end

ngx.req.read_body()
local args, err = ngx.req.get_post_args()
local phone_number = args.phone_number
local password = args.password
local access_token = args.access_token
local login_type = args.login_type

-- print(phone_number)
if not check_form(phone_number, password, login_type, access_token) then
	http_response.response_bad_request()
end

local conn = loadfile(ngx.var.root .. "/v1/helpers/mongo_connect.lua")()
local db = conn:new_db_handle(ngx.var.db_name)
local user_collection = db:get_col("user")
local user = user_collection:find_one({
	["phone_number"] = phone_number,
	["register_verified"] = true,
	["available"] = true
})

if user == nil then
	http_response.response_no_such_user()
end

if login_type == "password" then 
	if helper.crypt(password, user.salt) == user.password then
		access_token = helper.generate_salt()
		local n, err = user_collection:update({
			['phone_number'] = phone_number
		}, {
			["$set"] = {
				["signin_time"] = ngx.time(),
				["access_token"] = access_token
			}
		}, 1)
		if not n then
			print(n .. ' ' .. err)
			http_response.response_server_error()
		end
	else
		http_response.response_login_failed()
	end
elseif login_type == "access_token" then
	if user.access_token == access_token then 
		access_token = helper.generate_salt()
		local n, err = user_collection:update({
			['phone_number'] = phone_number
		}, {
			["$set"] = {
				["signin_time"]  = ngx.time(),
				["access_token"] = access_token
			}
		}, 1)
		if not n then 
			print(n .. ' ' .. err)
			http_response.response_server_error()
		end
	else
		http_response.response_login_fail()
	end
end

local response = {["data"] = {}}
user['_id'] = user['_id']:tostring()
user['access_token'] = access_token
user['portrait'] = "http://" .. const.upyun_domain .. "/" .. user['portrait']
for key, value in ipairs(const.user_info_response) do
	-- ngx.say(value)
	-- ngx.say(type(user[value]))
	response['data'][value] = user[value]
end
http_response.response_success(json.encode(response))
