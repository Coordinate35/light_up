local output = loadfile(ngx.var.root .. "/v2/core/output.lua")()
local helper = loadfile(ngx.var.root .. "/v2/helper/global_helper.lua")()
local const = loadfile(ngx.var.root .. "/v2/config/constants.lua")()
local zh_lang = loadfile(ngx.var.root .. "/v2/lang/chinese.lua")()
local json = loadfile(ngx.var.root .. "/v2/core/json.lua")()
local media = {}

function media:delete(args)
	local user_id = helper.to_object_id(args.user_id)
	local file_type = args.file_type
	local class = args.class
	local s_media = loadfile(ngx.var.root .. "/v2/service/media.lua")():new()
	local is_success, err = s_media:delete_media_by_user_id_and_class(file_type, user_id, class)
	if false == is_success then
		output.server_error("", err)
	end

	local response = {
		["status"] = zh_lang.delete_media_successfully,
		["data"] = {}
	}
	output.success(response)
end

function media:upload_audio(args)
	local bucket = const.upyun_audio_bucket
	local object_to_store = {
		["owner_id"] = helper.to_object_id(args.user_id),
		["sex"] = args.sex,
		["question_arr"] = json.decode(args.question_arr),
		["class"] = args[args.file_type .. "_class"],
		["time"] = ngx.time(),
		["available"] = true
	}
	self:_upload_media(args.file_type, object_to_store)
end

function media:upload_video(args)
	local bucket = const.upyun_video_bucket
	local object_to_store = {
		["owner_id"] = helper.to_object_id(args.user_id),
		["sex"] = args.sex,
		["save_key"] = args.save_key,
		["questions"] = json.decode(args.questions),
		["class"] = args[args.file_type .. "_class"],
		["time"] = ngx.time(),
		["available"] = true
	}
	self:_upload_media(args.file_type, object_to_store)
end

function media:_upload_media(file_type, object_to_store)
	local s_media = loadfile(ngx.var.root .. "/v2/service/media.lua")():new()
	local is_success, err = s_media:upsert_item(file_type, object_to_store)
	if false == is_success then
		output.server_error("", err)
	end

	local response = {
		["status"] = zh_lang.set_upload_media_successfully,
		["data"] = {}
	}
	output.success(response)
end

function media:new()
	return setmetatable({}, {__index = self})
end

return media