local c_procedure = loadfile(ngx.var.root .. "/v2/controller/procedure.lua")():new()

ngx.req.read_body()
local args, err = ngx.req.get_post_args()

c_procedure:get_user_ids_by_love_sex(args)
