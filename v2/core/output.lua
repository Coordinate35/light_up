local json = loadfile(ngx.var.root .. "/v2/core/json.lua")()
local zh_lang = loadfile(ngx.var.root .. "/v2/lang/chinese.lua")()

local output = {}

output._VERSION = "0.0.1"

function output.wrong_validate_code()
	status = ngx.HTTP_BAD_REQUEST
	msg = zh_lang.wrong_validate_code
	err = msg
	output.output_error(status, msg, err)
end

function output.server_error(msg, err)
	status = ngx.HTTP_INTERNAL_SERVER_ERROR
	msg = zh_lang.server_error
	output.output_error(status, msg, err)
end

function output.invalid_request(msg, err)
	status = ngx.HTTP_BAD_REQUEST
	msg = zh_lang.invalid_request .. ':' .. msg
	output.output_error(status, msg, err)
end

function output.forbidden(msg, err)
	status = ngx.HTTP_FORBIDDEN
	msg = zh_lang.forbidden .. ":" .. msg
	output.output_error(status, msg, err)
end

function output.accept(msg, err)
	status = ngx.HTTP_ACCEPTED
	output.output_error(status, msg, err)
end

function output.output_error(status, msg, err)
	print(err)
	local response = {
		["error"] = msg
	}
	ngx.status = status
	ngx.say(json.encode_empty_as_object(response))
	ngx.exit(ngx.HTTP_OK)
end

function output.success(response)
	ngx.status = ngx.HTTP_OK
	ngx.say(json.encode_empty_as_object(response))
	ngx.exit(ngx.HTTP_OK)
end


return output