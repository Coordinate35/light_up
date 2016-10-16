local json = loadfile(ngx.var.root .. "/v2/core/json.lua")()
local output = loadfile(ngx.var.root .. "/v2/core/output.lua")()
local zh_lang = loadfile(ngx.var.root .. "/v2/lang/chinese.lua")()

local response = {}
ngx.req.read_body()
local args, err = ngx.req.get_post_args()
if not args then
	err = "获取post参数失败: " .. err
	output.invalid_request("", err)
end

local form_validation = loadfile(ngx.var.root .. "/v2/core/form_validation.lua")()
local form_check_config = loadfile(ngx.var.root .. "/v2/config/form_check_config.lua")()
local check_item = form_check_config.change_personal_info
local result, err = form_validation.check(args, check_item)
if false == result then
	output.invalid_request(err, err)
end

local personal_info = json.decode(args.personal_info)
if nil ~= personal_info.sex then
	local s_account = loadfile(ngx.var.root .. "/v2/service/account.lua")():new()
	local result = s_account:isset_sex(args.user_id)
	if true == result then
		msg = zh_lang.sex_is_set
		output.forbidden(msg, msg)
	end
end