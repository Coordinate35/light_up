local const = loadfile(ngx.var.root .. "/v1/constants/constants.lua")()
local json = require("cjson")

local upyun = {}

function upyun.generate_policy(bucket, expiration, save_key)
	local policy = {}
	policy.bucket = bucket
	policy.expiration = expiration
	policy["save-key"] = save_key
	policy = json.encode(policy)
	policy = ngx.encode_base64(policy)
	return policy
end

function upyun.generate_signature(policy, upyun_form_key)
	local signature = policy .. "&" .. upyun_form_key
	return ngx.md5(signature)
end

return upyun
