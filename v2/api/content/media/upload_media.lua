local c_media = loadfile(ngx.var.root .. "/v2/controller/media.lua")():new()

ngx.req.read_body()
local args, err = ngx.req.get_post_args()

local switch = {
	["audio"] = "upload_audio",
	["video"] = "upload_video"
}

c_media[switch[args.file_type]](c_media, args)
