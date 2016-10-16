local json = loadfile(ngx.var.root .. "/v2/core/json.lua")()
local output = loadfile(ngx.var.root .. "/v2/core/output.lua")()
local zh_lang = loadfile(ngx.var.root .. "/v2/lang/chinese.lua")()

local response = {}
ngx.req.read_body()
local args, err = ngx.req.get_post_args()
if not args then
	err = zh_lang.get_post_args_failed .. ": " .. err
	output.invalid_request("", err)
end

local form_validation = loadfile(ngx.var.root .. "/v2/core/form_validation.lua")()
local form_check_config = loadfile(ngx.var.root .. "/v2/config/form_check_config.lua")()
local check_item = form_check_config.delete_media
local result, err = form_validation.check(args, check_item)
if false == result then
	output.invalid_request(err, err)
end

local s_account = loadfile(ngx.var.root .. "/v2/service/account.lua")():new()
local result = s_account:is_logined(args.user_id, args.access_token)
if false == result then
	local msg = zh_lang.not_logined
	output.invalid_request(msg, msg)
elseif nil == result then
	local msg = ""
	local err = "Get user failed"
	output.server_error(msg, err)
end