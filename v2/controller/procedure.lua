local output = loadfile(ngx.var.root .. "/v2/core/output.lua")()
local helper = loadfile(ngx.var.root .. "/v2/helper/global_helper.lua")()
local const = loadfile(ngx.var.root .. "/v2/config/constants.lua")()
local zh_lang = loadfile(ngx.var.root .. "/v2/lang/chinese.lua")()
local json = loadfile(ngx.var.root .. "/v2/core/json.lua")()
local s_procedure = loadfile(ngx.var.root .. "/v2/service/procedure.lua")():new()
local random = require("resty.random")
local procedure = {}

function procedure:log_have_seen(args)
	local user_id = helper.to_object_id(args.user_id)
	local target_id = helper.to_object_id(args.target_id)
	local is_success, err = s_procedure:log_have_seen(user_id, target_id)
	if false == is_success then
		output.server_error("", err)
	end

	local response = {
		["status"] = zh_lang.log_have_seen_successfully,
		["data"] = {}
	}
	output.success(response)
end

function procedure:light_up(args)
	local user_id = helper.to_object_id(args.user_id)
	local target_id = helper.to_object_id(args.target_id)
	local order = args.order
	local available
	if "0" == args.light_status then
		available = false
	end
	if "1" == args.light_status then
		available = true
	end

	local is_user_info_complete, err = s_procedure:is_user_media_complete(user_id)
	if nil == is_user_info_complete then
		output.server_error("", err)
	end

	if false == is_user_info_complete then
		local today_timestamp = helper.get_today_timestamp()
		local today_light_numbers, err = s_procedure:get_day_light_number(user_id, today_timestamp)
		if false == today_light_numbers then
			output.server_error("", err)
		end
		if const.day_light_up_number_for_uncomplete_user <= today_light_numbers then
			local msg = zh_lang.day_light_up_limit_for_uncomplete
			output.forbidden(msg, msg)
		end	
	end

	local is_success, err = s_procedure:set_previous_light_unavailable(user_id, target_id, order)
	if false == is_success then
		output.server_error("", err)
	end

	is_success, err = s_procedure:light_up(user_id, target_id, order, available)
	if false == is_success then
		output.server_error("", err)
	end

	local response = {
		["status"] = zh_lang.light_up_successfully,
		["data"] = {}
	}
	output.success(response)
end

function procedure:get_message(args)
	local user_id = helper.to_object_id(args.user_id)
	local logs, err = s_procedure:get_message(user_id)
	if false == logs then
		output.server_error("", err)
	end

	if nil == logs then
		local msg = zh_lang.no_more_message
		output.accept(msg, "")
	end

	local response = {
		["status"] = zh_lang.get_message_successfully,
		["data"] = {
			["logs"] = logs
		}
	}
	output.success(response)
end

function procedure:get_user_ids_by_love_sex(args)
	local user_id = helper.to_object_id(args.user_id)
	local love_sex = args.love_sex
	local time_segment_upper_edge = self:_get_time_segment_upper_edge()
	local today_timestamp = helper.get_today_timestamp()

	local segment_have_seen_users, err = s_procedure:get_have_seen_users(user_id, time_segment_upper_edge)
	if false == segment_have_seen_users then
		output.server_error("", err)
	end
	if const.allow_get_user_number_per_segment <= #segment_have_seen_users then
		local err = zh_lang.segment_uplimit
		output.forbidden(err, err)
	end

	-- local day_have_seen_users = s_procedure:get_have_seen_users(user_id, today_timestamp)
	local day_have_seen_users
	local is_user_media_complete , err = s_procedure:is_user_media_complete(user_id)
	if nil == is_user_media_complete then
		output.server_error("", err)
	end
	if false == is_user_media_complete then 
		day_have_seen_users = s_procedure:get_have_seen_users(user_id, today_timestamp)
		if false == day_have_seen_users then
			output.server_error("", err)
		end
		if const.allow_get_user_number_for_uncomplete_media_user_per_day < #day_have_seen_users then
			local err = zh_lang.day_uplimit_for_uncomplete_user
			output.forbidden(err, err)
		end
	end

	local segment_left_number = const.allow_get_user_number_per_segment - #segment_have_seen_users
	local need_guest_number = segment_left_number
	local have_seen_set = segment_have_seen_users
	if false == is_user_media_complete then
		local day_left_number = const.allow_get_user_number_for_uncomplete_media_user_per_day - #day_have_seen_users
		if segment_left_number >= day_left_number then
			have_seen_set = day_have_seen_users
			need_guest_number = day_left_number
		end
	end

	local guest, err = s_procedure:get_guest_by_sex(love_sex)
	if false == guest then
		output.server_error("", err)
	end
	guest = self:_filter_redundent_guest(guest, have_seen_set)
	guest, err = self:_get_random_guest(guest, need_guest_number)
	if false == guest then
		output.server_error("", err)
	end
	guest, err = self:_count_light_number(user_id, guest)
	if false == guest then
		output.server_error("", err)
	end

	local response = {
		["status"] = zh_lang.get_user_ids_by_love_sex_successfully,
		["data"] = guest
	}
	output.success(response)
end

function procedure:_filter_redundent_guest(guest, have_seen_set)
	for have_seen_set_key, have_seen_set_value in pairs(have_seen_set) do
		for guest_key, guest_value in pairs(guest) do
			if guest_value == have_seen_set_value then
				table.remove(guest, guest_key)
			end
		end
	end
	return guest
end

function procedure:_get_random_guest(guest, need_guest_number)
	if #guest < need_guest_number then
		return false, zh_lang.no_more_guest
	end

	local chosen_guest = {}
	while need_guest_number > 0 do
		local index = random.number(1, need_guest_number)
		table.insert(chosen_guest, guest[index])
		need_guest_number = need_guest_number - 1
	end
	return chosen_guest, nil
end

function procedure:_get_time_segment_upper_edge()
	local current_time = ngx.time()
	local today_timestamp = helper.get_today_timestamp()
	local today_has_been = current_time - today_timestamp
	if today_has_been < const.day_first_change_segment_second then
		return today_timestamp - const.last_day_lasy_change_segment_from_today
	end
	today_has_been = const.day_first_change_segment_second
	local this_segment_has_been = today_has_been
	local i = 1
	while this_segment_has_been - const.segment_long[i] > 0 do
		i = i + 1
		this_segment_has_been =  this_segment_has_been - const.segment_long[i]
	end
	return current_time - this_segment_has_been
end

function procedure:_count_light_number(user_id, guest)
	local guest_with_light_number = {}
	for key, value in pairs(guest) do
		local light_number, err = s_procedure:count_user_light_user_number(user_id, value)
		if false == light_number then
			output.server_error("", err)
		end
		guest_with_light_number[key] = {
			["user_id"] = value:tostring(),
			["have_light_number"] = light_number
		}
	end

	return guest_with_light_number, nil
end

function procedure:get_video(args)
	local target_id = helper.to_object_id(args.target_id)
	local class = args.class
	local video, err = s_procedure:get_media("video", target_id, class)
	if false == video then
		output.server_error("", err)
	end

	local response = {
		["status"] = zh_lang.get_media_successfully,
		["data"] = {
			["save_key"] = const.upyun_protocol .. const.upyun_domain .. video.save_key,
			["questions"] = video.questions
		}
	}

	for key, value in pairs(video.questions) do
		local question_content, err = s_procedure:get_question_content_by_id_and_class(value.question_id, class)
		if false == question_content then
			output.server_error("", err)
		end
		response["data"].questions[key].question_content = question_content
	end
	output.success(response)
end

function procedure:get_audio(args)
	local target_id = helper.to_object_id(args.target_id)
	local class = args.class
	local audio, err = s_procedure:get_media("audio", target_id, class)
	if false == audio then
		output.server_error("", err)
	end

	for key, value in pairs(audio.question_arr) do
		local question_content, err = s_procedure:get_question_content_by_id_and_class(value.question_id, class)
		if false == question_content then
			output.server_error("", err)
		end
		audio.question_arr[key].question_content = question_content
		audio.question_arr[key].save_key = const.upyun_protocol .. const.upyun_domain .. audio.question_arr[key].save_key
	end

	local response = {
		["status"] = zh_lang.get_media_successfully,
		["data"] = {
			["questions"] = audio.question_arr
		}
	}
	output.success(response)
end

function procedure:new()
	return setmetatable({}, {__index = self})
end

return procedure