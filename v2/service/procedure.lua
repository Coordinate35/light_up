local const = loadfile(ngx.var.root .. "/v2/config/constants.lua")()
local procedure_service = {}

function procedure_service:log_have_seen(user_id, target_id)
	local m_time_have_seen_log = loadfile(ngx.var.root .. "/v2/model/time_have_seen_log.lua")():new()
	local time = ngx.time()
	local is_success, err = m_time_have_seen_log:log_have_seen(user_id, target_id, time)
	if not is_success then
		return false, err
	end
	return true, nil
end

function procedure_service:get_day_light_number(user_id, today_timestamp)
	local day_start = today_timestamp
	local day_end = today_timestamp + const.one_day_second
	local m_light_log = loadfile(ngx.var.root .. "/v2/model/light_log.lua")():new()
	local number = m_light_log:count_user_light_number_by_time_section(user_id, day_start, day_end)
	if not number then
		return false, "Get user light number by time section failed"
	end
	return number
end

function procedure_service:set_previous_light_unavailable(user_id, target_id, order)
	local m_light_log = loadfile(ngx.var.root .. "/v2/model/light_log.lua")():new()
	local is_success, err = m_light_log:set_previous_light_unavailable(user_id, target_id, order)
	if not is_success then
		return false, err
	end
	return true, nil
end

function procedure_service:light_up(user_id, target_id, order, available)
	local m_light_log = loadfile(ngx.var.root .. "/v2/model/light_log.lua")():new()
	local time = ngx.time()
	local is_success, err = m_light_log:light_up(user_id, target_id, order, available, time)
	if not is_success then
		return false, err
	end
	return true, nil
end

function procedure_service:get_message(user_id)
	local last_get_message_time, err = self:_get_last_get_message_time(user_id)
	if false ==  last_get_message_time then
		return false, err
	end
	local logs, err = self:_get_user_last_light_been_light_log(user_id, last_get_message_time)
	if false == logs then
		return false, err
	end
	local logs, err = self:_add_user_info_for_message(logs)
	if false == logs then
		return false, err
	end
	return logs, nil
end

function procedure_service:_get_last_get_message_time(user_id)
	local m_get_message_log = loadfile(ngx.var.root .. "/v2/model/get_message_log.lua")():new()
	local get_message_log_cursor = m_get_message_log:get_log_cursor(user_id)
	if not get_message_log_cursor then
		return false, "Get get message log cursor failed"
	end

	local sorted_result = get_message_log_cursor:sort({
			["time"] = -1
		}
	)
	if nil == sorted_result[1] then
		return 0, nil
	else
		return sorted_result[1]["time"], nil
	end
end

function procedure_service:_get_user_last_light_been_light_log(user_id, last_get_message_time)
	local m_light_log = loadfile(ngx.var.root .. "/v2/model/light_log.lua")():new()
	local log_cursor = m_light_log:get_user_last_light_been_light_log_cursor_from_time(user_id, last_get_message_time, tostring(const.last_ligth_order))
	if not log_cursor then
		return false, "Get light log cursor failed"
	end

	local logs = {}
	for key, value in log_cursor:pairs() do
		logs[key] = value
	end
	return logs, nil
end

function procedure_service:_add_user_info_for_message(logs)
	local result = {}
	local m_user = loadfile(ngx.var.root .. "/v2/model/user.lua")():new()
	for key, value in pairs(logs) do
		local user = m_user:get_user_by_user_id(value.user_id)
		if not user then
			return false, "Get user " .. value.user_id:tostring() .. " failed"
		end
		user = self._filter_out_user_portrait_nickname(user)
		user.portrait = const.upyun_protocol .. const.upyun_domain .. user.portrait
		value.lighter = user
		value._id = value._id:tostring()
		value.content = zh_lang.i_have_light_for_you
		value.order = nil
		value._id = nil
		value.available = nil
		value.user_id = nil
		value.target_id = nil
		table.insert(result, value)
		return result
	end
end

function procedure_service:_filter_out_user_portrait_nickname_id(user)
	local result = {
		["user_id"] = user._id:tostring(),
		["protrait"] = user.portrait,
		["nickname"] = user.nickname
	}
	return result
end

function procedure_service:count_user_light_user_number(user_id, target_id)
	local m_light_log = loadfile(ngx.var.root .. "/v2/model/light_log.lua")():new()
	local light_number = m_light_log:count_user_light_user_number(user_id, target_id)
	if not light_number then
		return false, "Count user been light number failed"
	end
	return light_number, nil
end

function procedure_service:get_have_seen_users(user_id, from_time)
	local m_time_have_seen_log = loadfile(ngx.var.root .. "/v2/model/time_have_seen_log.lua")():new()
	local have_seen_user_cursor = m_time_have_seen_log:get_have_seen_users_cursor(user_id, from_time)
	if nil == have_seen_user_cursor then
		return false, "Get have seen user cursor failed"
	end
	
	local have_seen_user = {}
	for key, value in have_seen_user_cursor:pairs() do
		have_seen_user[key] = value.target_id
	end
	return have_seen_user, nil
end

function procedure_service:is_user_media_complete(user_id)
	for key, value in pairs(const.all_class) do
		local m_class = loadfile(ngx.var.root .. "/v2/model/" .. value.media_type .. ".lua")():new()
		local is_complete = m_class:get_item_by_user_id_and_class(user_id, value.class)
		if nil == is_complete then
			return false, nil
		end
		if 0 == is_complete then
			return false, nil
		end
	end
	return true, nil
end

function procedure_service:get_guest_by_sex(sex)
	local m_video = loadfile(ngx.var.root .. "/v2/model/video.lua")():new()
	local candidate_cursor = m_video:get_item_by_sex_and_class(sex, "value_concept")
	if not condidate_cursor then
		return false, "Get guest by sex failed"
	end

	local guests = {}
	for key, value in candidate_cursor:pairs() do 
		guests[key] = value.owner_id
	end

	for key, value in pairs(guests) do 
		local is_complete, err = self:is_user_media_complete(value)
		if false == is_complete then
			table.remove(guests, key)
		end
	end

	return guests, nil
end

function procedure_service:get_question_content_by_id_and_class(question_id, class)
	local m_question = loadfile(ngx.var.root .. "/v2/model/question.lua")():new()
	if false == m_question:select_collection(class) then
		return false, "Select question collection failed"
	end
	local question = m_question:get_question_by_id(question_id)
	if false == question or not question then
		return false , "Get question content failed"
	end
	return question.question_content, nil
end

function procedure_service:get_media(file_type, user_id, class)
	local m_media = loadfile(ngx.var.root .. "/v2/model/" .. file_type .. ".lua")():new()
	local media_item = m_media:get_item_by_user_id_and_class(user_id, class)
	if not media_item then
		return false, "Get media item failed"
	end
	return media_item, nil
end

function procedure_service:new()
	return setmetatable({}, {__index = self})
end

return procedure_service