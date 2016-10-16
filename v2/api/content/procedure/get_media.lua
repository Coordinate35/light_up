local c_procedure = loadfile(ngx.var.root .. "/v2/controller/procedure.lua")():new()

ngx.req.read_body()
local args, err = ngx.req.get_post_args()

local switch = {
	["audio"] = "get_audio",
	["video"] = "get_video"
}

c_procedure[switch[args.file_type]](c_procedure, args)
