local helper = {}
local output = loadfile(ngx.var.root .. "/v2/core/output.lua")()
local random = require("resty.random")
local mongo_id = require("resty.mongol.object_id")
local resty_string = require("resty.string")

function helper.get_today_timestamp()
	local time_table = os.date("*t")
	local year = time_table.year
	local month = time_table.month
	local day = time_table.day
	local hour = time_table.hour
	local half_day_second = 43200
	local today_timestamp = os.time{year = year, month = month, day = day} - half_day_second
	return today_timestamp
end

function helper.get_age(time)
	if 0 == #tostring(time) then
		return 0
	end
	local life_time = math.floor(tonumber(ngx.time())) - math.floor(tonumber(time))
	local age = math.floor(life_time / const.one_year_have_second)
	return age
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
			["Authorization"] = "Basic <base64 code>"
		},
		ssl_verify = false
	})
	if not res then
		-- print("failed to send sms:", err)
		local msg = "发送验证码失败"
		output.server_error(msg, err)
	end
	print(res.body)
	print("message sended")
end

function helper.atoi(str)
	str = tonumber(str)
	if nil == str then 
		return nil
	end
	return math.floor(str)
end

function helper.split(str, delimiter)
	if nil == str or '' == str or nil == delimiter then
		return nil
	end
	local result = {}
	local params_num = 0
	local str = str .. delimiter
	for match in str:gmatch("(.-)" .. delimiter) do
		table.insert(result, match)
		params_num = params_num + 1
	end
	local last_length = #result[params_num]
	if "%" == string.sub(result[params_num], last_length, last_length) then
		result[params_num] = string.sub(result[params_num], 1, last_length - 1)
	end
	return result
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

function helper.generate_validate_code()
	return random.number(100000, 999999)
end

function helper.generate_access_token()
	return helper.generate_salt()
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