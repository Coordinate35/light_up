local mongo_id = require("resty.mongol.object_id")
local random = require("resty.random")
local json = require("cjson")
local resty_string = require("resty.string")
local http_response = loadfile(ngx.var.root .. "/v1/helpers/http_response.lua")()
local const = loadfile(ngx.var.root .. "/v1/constants/constants.lua")()

local helper = {}

function helper.is_complete(db, user_id)
	for key, value in pairs(const.part) do
		local collection = db:get_col(value.media_type)
		local has = collection:count({
				["owner_id"] = user_id,
				["available"] = true,
				["class"] = value.class
			}
		)
		if nil == has then
			http_response.response_server_error()
		end
		if 0 == has then
			return false
		end
	end
	return true
end

function helper.in_array(target, arr)
	for key, value in pairs(arr) do
		if value == arr[key] then
			return true
		end
	end
	return false
end

function helper.get_segment(timestamp)
	print(timestamp)
	for key, value in pairs(const.segment_define) do
		if value.from <= timestamp and value.to > timestamp then
			return key
		end
	end
end

function helper.get_today_name(timestmap)
    return os.date("%Y-%m-%d", timestamp)
end

function helper.get_question_by_id(question_id, class)
	local conn = loadfile(ngx.var.root .. "/v1/helpers/mongo_connect.lua")()
	local db = conn:new_db_handle(ngx.var.db_name)
	local question_collection = db:get_col(class)
	local question = question_collection:find_one({
		["_id"] = helper.to_object_id(question_id),
		["available"] = true
	})
	if not question then 
		http_response.response_server_error()
	end
	return question.question_content
end

function helper.get_light_number(light_log_collection, user_id, class)
	local n = light_log_collection:count({
			["target_id"] = user_id,
			["available"] = true,
			["order"] = tostring(const[class .. "_order"])
		}
	)
	print(n)
	return n
end

function helper.get_age(time)
	local life_time = math.floor(tonumber(ngx.time())) - math.floor(tonumber(time))
	-- print(math.floor(tonumber(ngx.time())))
	-- print(math.floor(tonumber(time)))
	-- print(life_time)
	local age = math.floor(life_time / const.one_year_have_second)
	return age
end

function helper.to_object_id(str)
    assert(#str == 24)
    local raw = helper.hex2raw(str)
    assert(#raw == 12)
    return mongo_id.new(raw)
end

function helper.hex2raw(str)
    assert(#str % 2 == 0)
    ret = {}
    for i = 1, #str, 2 do
        ret[#ret+1] = string.char(tonumber(string.sub(str, i, i+1), 16))
    end
    return table.concat(ret, "")
end

function helper.is_refreshable(_id, access_token)
	local user = helper.get_user_by_id(_id)
	local has_been = tonumber(ngx.time()) - math.floor(tonumber(user.signin_time))
	-- print(has_been)
	-- print(math.floor(tonumber(const.token_refreshable_time)))
	if has_been > math.floor(tonumber(const.token_refreshable_time)) then
		-- _M.response_access_token_expired()		
		return false
	end
	if access_token ~= user.access_token then
		-- _M.response_access_not_match()
		return false
	end
	return true
end

function helper.is_logined(_id, access_token)
	local user = helper.get_user_by_id(_id)
	local has_been = tonumber(ngx.time()) - math.floor(tonumber(user.signin_time))
	if has_been > math.floor(tonumber(const.token_expire_time)) then
		-- _M.response_access_token_expired()		
		return false
	end
	if access_token ~= user.access_token then
		-- _M.response_access_not_match()
		return false
	end
	return true
end

function helper.is_personal_info_changeable(_id, access_token)
	local user = helper.get_user_by_id_no_matter_available(_id)
	local has_been = tonumber(ngx.time()) - math.floor(tonumber(user.signin_time))
	if has_been > math.floor(tonumber(const.token_expire_time)) then
		-- _M.response_access_token_expired()		
		return false
	end
	if access_token ~= user.access_token then
		-- _M.response_access_not_match()
		return false
	end
	if not user.register_verified then
		return false
	end
	return true
end

function helper.get_user_by_id_no_matter_available(_id)
	local conn = loadfile(ngx.var.root .. "/v1/helpers/mongo_connect.lua")()
	local db = conn:new_db_handle(ngx.var.db_name)
	local user_collection = db:get_col("user")
	local user = user_collection:find_one({
		["_id"] = _id
	})
	if not user then 
		http_response.response_server_error()
	end
	return user
end

function helper.get_user_by_id(_id)
	local conn = loadfile(ngx.var.root .. "/v1/helpers/mongo_connect.lua")()
	local db = conn:new_db_handle(ngx.var.db_name)
	local user_collection = db:get_col("user")
	local user = user_collection:find_one({
		["_id"] = _id,
		["available"] = true
	})
	if not user then 
		http_response.response_server_error()
	end
	return user
end

function helper.send_validate_code(phone_number, validate_code)
	local http_body = "mobile=" .. phone_number .. "&message=" .. ngx.escape_uri("验证码：" .. validate_code .. "【亮灯】")
	local http = require "resty.http"
	local httpc = http.new()
	local res, err = httpc:request_uri("https://sms-api.luosimao.com/v1/send.json", {
		method = "POST",
		body = http_body,
		headers = {
			["Content-Type"] = "application/x-www-form-urlencoded",
			["Authorization"] = "Basic base64 code"
		},
		ssl_verify = false
	})
	if not res then
		print("failed to send sms:", err)
		http_response.response_server_error()
	end
	print(res.body)
	print("message sended")
end

function helper.generate_validate_code()
	return random.number(100000, 999999)
end

function helper.generate_salt()
	local str = random.bytes(8)
	return ngx.md5(str)
end

function helper.crypt(raw, salt)
	local digest
	local object = salt .. raw
	local i = {1, 2, 3, 4, 5, 6, 7, 8}
	local resty_sha256 = require("resty.sha256")
	for _, v in ipairs(i) do
		sha256 = resty_sha256:new()
		sha256:update(object)
		digest = sha256:final()
		object = resty_string.to_hex(digest)
	end
	return object
end

return helper
