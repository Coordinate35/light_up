local c_user = loadfile(ngx.var.root .. "/v2/controller/user.lua")():new()

ngx.req.read_body()
local args, err = ngx.req.get_post_args()

c_user:get_account_questions(args)
