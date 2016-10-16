local mongo_id = require("resty.mongol.object_id")
local random = require("resty.random")
local json = require("cjson")
local resty_string = require("resty.string")
local const = loadfile(ngx.var.root .. "/v1/constants/constants.lua")()

local http_response = {}

function http_response.response_segment_limit()
	status = ngx.HTTP_FORBIDDEN
	body = "This segment limit number has been reached"
	http_response.response(status, body)
end

function http_response.response_no_more_guest()
	status = ngx.HTTP_ACCEPTED
	body = "no more guests"
	http_response.response(status, body)
end

function http_response.response_segment_allow_guest_number_uplimit()
	status = ngx.HTTP_FORBIDDEN
	body = "Your guests have reach uplimit in this time segment"
	http_response.response(status, body)
end

function http_response.response_day_allow_guest_number_uplimit_for_uncomplete()
	status = ngx.HTTP_FORBIDDEN
	body = "Your cant only get these guests because you havent complete your media info"
	http_response.response(status, body)
end

function http_response.response_light_number_uplimit()
	status = ngx.HTTP_FORBIDDEN
	body = "Your light up time is more than the limit"
	http_response.response(status, body)
end

function http_response.response_nickname_has_been_used()
	status = ngx.HTTP_ACCEPTED
	body = "This nickname has already been used"
	http_response.response(status, body)
end

function http_response.response_no_guest()
	status = ngx.HTTP_OK
	body = "No guests"
	http_response.response(status, body)
end

function http_response.no_such_media()
	status = ngx.HTTP_BAD_REQUEST
	body = "No such media"
	http_response.response(status, body)
end

function http_response.not_such_audio()
	status = ngx.HTTP_BAD_REQUEST
	body = "No such audio"
	http_response.response(status, body)
end

function http_response.no_such_response()
	status = ngx.HTTP_BAD_REQUEST
	body = "You haven't sent this request"
	http_response.response(status, body)
end

function http_response.response_access_token_expired()
	status = ngx.HTTP_UNAUTHORIZED
	body = "access_token has expired, please relogin"
	http_response.response(status, body)
end

function http_response.response_not_logined()
	status = ngx.HTTP_UNAUTHORIZED
	body = "You haven't logined"
	http_response.response(status, body)
end

function http_response.response_login_failed()
	status = ngx.HTTP_BAD_REQUEST
	body = "phone_number and password don't match"
	http_response.response(status, body)
end

function http_response.response_no_such_user()
	status = ngx.HTTP_BAD_REQUEST
	body = "no such user"
	http_response.response(status, body)
end

function http_response.response_validate_code_not_right()
	status = ngx.HTTP_BAD_REQUEST
	body = "validate code not right"
	http_response.response(status, body)
end

function http_response.response_success(content)
	ngx.status = ngx.HTTP_OK
	ngx.say(content)
	ngx.exit(ngx.HTTP_OK)
end

function http_response.response_bad_request()
	status = ngx.HTTP_BAD_REQUEST
	body = "invalid request"
	http_response.response(status, body)
end

function http_response.response_server_error()
	status = ngx.HTTP_INTERNAL_SERVER_ERROR
	body = "server error"
	http_response.response(status, body)
end

function http_response.response_has_user()
	status = ngx.HTTP_ACCEPTED
	body = "This user has already exist"
	http_response.response(status, body)
end

function http_response.response_sms_not_verified()
	status = ngx.HTTP_UNAUTHORIZED
	body = "you haven't prove yourself"
	http_response.response(status, body)
end

function http_response.response(status, body)
	ngx.status = status
	local response = {
		["error"] = body
	}
	ngx.say(json.encode(response))
	ngx.exit(ngx.HTTP_OK)
end

return http_response
