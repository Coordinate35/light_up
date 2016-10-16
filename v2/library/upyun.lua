local json = require "cjson"

local upyun = {}

upyun._VERSION = "0.0.1"

function upyun:generate_policy(bucket, expiration, save_key)
	local policy = {}
	policy.bucket = bucket
	policy.expiration = expiration
	policy["save-key"] = save_key
	policy = json.encode(policy)
	policy = ngx.encode_base64(policy)
	return policy
end

function upyun:generate_signature(policy)
	local signature = policy .. "&" .. self._upyun_form_key
	return ngx.md5(signature)
end

function upyun:new(upyun_form_key)
	self._upyun_form_key = upyun_form_key
    return setmetatable({}, {__index = self})
end

return upyun