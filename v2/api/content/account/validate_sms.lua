local c_user = loadfile(ngx.var.root .. "/v2/controller/user.lua")():new()

ngx.req.read_body()
local args, err = ngx.req.get_post_args()

local switch = {
	["register"] = "pass_validate_sms_register",
	["change_password"] = "pass_validate_sms_change_password"
}

c_user[switch[args.validate_type]](c_user, args)
