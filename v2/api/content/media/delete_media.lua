local c_media = loadfile(ngx.var.root .. "/v2/controller/media.lua")():new()

ngx.req.read_body()
local args, err = ngx.req.get_post_args()

c_media:delete(args)
