local account_service = {}
local m_question = loadfile(ngx.var.root .. "/v2/model/question.lua")():new()
local m_user = loadfile(ngx.var.root .. "/v2/model/user.lua")():new()
local helper = loadfile(ngx.var.root .. "/v2/helper/global_helper.lua")()
local const = loadfile(ngx.var.root .. "/v2/config/constants.lua")()
local zh_lang = loadfile(ngx.var.root .. "/v2/lang/chinese.lua")()

function account_service:update_portrait(user_id)
	local m_portrait_buffer = loadfile(ngx.var.root .. "/v2/model/portrait_buffer.lua")():new()
	local buffer, err = m_portrait_buffer:get_user_buffer(user_id)
	if not buffer or 0 == buffer then 
		return false, err
	end
	local personal_info = {
		["portrait"] = buffer.save_key
	}
	local n, err = m_user:change_personal_info(user_id, personal_info)
	if not n then
		return false, err
	end

	local n, err = m_portrait_buffer:delete_item(user_id)
	return true, nil
end

function account_service:add_portrait_buffer(storing_info)
	local m_portrait_buffer = loadfile(ngx.var.root .. "/v2/model/portrait_buffer.lua")():new()
	local n, err = m_portrait_buffer:add_item(storing_info)
	if not n then
		return false, err
	else
		return true, nil
	end
end

function account_service:refresh_device_token(user_id, device_token)
	local m_device_token = loadfile(ngx.var.root .. "/v2/model/device_token.lua")():new()
	local create_time = ngx.time()
	local n, err = m_device_token:insert_item(user_id, device_token, create_time)
	if not n then
		return false, err
	else
		return true, nil
	end
end

function account_service:has_complete(media_type, class, target_id)
	local m_media = loadfile(ngx.var.root .."/v2/model/" .. media_type .. ".lua")():new()
	local number = m_media:count_by_class(target_id, class)
	if nil == number then 
		local err = "Judge has complete failed"
		return nil, err
	end
	if 0 < number then
		return true, nil
	else
		return false, nil
	end
end

function account_service:get_user_info(target_id)
	local user = m_user:get_user_by_user_id(target_id)
	if nil == user then
		local err = "Get target user failed."
		return false, err
	end
	user = self:filter_irresponsable_user_info(user)
	user.age = helper.get_age(user.birthday)
	for key, value in pairs(const.all_class) do
		local result, err = self:has_complete(value.media_type, value.class, target_id)
		if nil == result then
			return false, err
		end
		user[value.class .. "_complete"] = result
		local m_light_log = loadfile(ngx.var.root .. "/v2/model/light_log.lua")():new()
		local number = m_light_log:count_by_order(target_id, value.order)
		if nil == number then
			local err = "Count light number failed"
			return false, err
		end
		user[value.class .. "_light_number"] = number
	end
	return user, nil
end

function account_service:filter_class_questions(user, class)
	return user.questions[class]
end

function account_service:get_account_questions(user_id, class)
	local user = m_user:get_user_by_user_id(user_id)
	if nil == user then
		return false
	end
	return self:filter_class_questions(user, class)
end

function account_service:change_password_prepare(phone_number, validate_code)
	local is_success, err = m_user:set_change_password_unverified(phone_number, validate_code)
	if nil == is_success or 0 == is_success then
		return false ,err
	end
	return true, nil
end

function account_service:is_password_changeable(phone_number)
	local user = m_user:get_all_user_by_phone_number(phone_number)
	if nil == user then
		return false
	end
	if false == user.change_password_verified then
		return false
	end
	return true
end

function account_service:access_token_refreshable(signin_time)
	local has_been = ngx.time() - signin_time
	if has_been > const.token_refreshable_time then
		return false
	end
	return true
end

function account_service:is_token_refreshable(user_id, access_token)
	user_id = helper.to_object_id(user_id)
	local user = m_user:get_all_user_by_user_id(user_id)
	if nil == user then 
		return nil
	end
	if false == account_service:access_token_refreshable(user.signin_time) then 
		return false
	end
	if user.access_token ~= access_token then
		return false
	end
	return true
end

function account_service:access_token_expires(signin_time)
	local has_been = ngx.time() - signin_time
	if has_been > const.token_expires_time then
		return true
	end
	return false
end

function account_service:password_login_check(phone_number, password)
	local user = m_user:get_user_by_phone_number(phone_number)
	if false == user then
		return false
	end
	if helper.crypt(password, user.salt) ~= user.password then
		return false
	end
	return true
end

function account_service:access_token_login_check(phone_number, access_token)
	local user = m_user:get_user_by_phone_number(phone_number)
	if false == user then
		return false
	end
	if access_token ~= user.access_token then 
		return false
	end
	if false == account_service:access_token_refreshable(user.signin_time) then 
		return false
	end
	return true
end

function account_service:filter_irresponsable_user_info(user)
	local user_info_responsable = {
		"_id",
		"portrait",
		"phone_number",
		"access_token",
		"nickname",
		"weibo_nickname",
		"wechat_nickname",
		"weibo_uid",
		"wechat_uid",
		"wechat_ID",
		"sex",
		"love_sex",
		"birthday",
		"location"
	}
	local user_info = {}
	for key, value in pairs(user_info_responsable) do
		user_info[value] = user[value]
	end
	user_info.user_id = user_info._id:tostring()
	user_info._id = nil
	if 0 ~= #user_info.portrait then
		user_info.portrait = const.upyun_domain .. "/" .. user_info.portrait
	end
	return user_info
end

function account_service:refresh_access_token_get_user_info(phone_number)
	local user = m_user:get_user_by_phone_number(phone_number)
	if false == user then
		local err = zh_lang.get_user_failed
		return false, err
	end
	local access_token, err = self:refresh_access_token(user._id)
	if false == access_token then
		return access_token, err
	end
	user.access_token = access_token
	return self:filter_irresponsable_user_info(user)
end

function account_service:refresh_access_token(user_id)
	local access_token = helper.generate_access_token()
	local personal_info = {
		["access_token"] = access_token,
		["signin_time"] = ngx.time()
	}
	local is_success, err = self:change_personal_info(user_id, personal_info)
	if false == is_success then
		return is_success, err
	else
		return access_token, nil
	end
end

function account_service:change_personal_info(user_id, personal_info)
	local n, err = m_user:change_personal_info(user_id, personal_info)
	if nil == n then 
		return false, err
	end
	return true, err
end

function account_service:isset_sex(user_id)
	user_id = helper.to_object_id(user_id)
	local user = m_user:get_all_user_by_user_id(user_id)
	if nil == user then
		return false
	end
	if "" == user.sex then
		return false
	end
	return true
end

function account_service:filter_user_id(user)
	return user._id:tostring()
end

function account_service:get_user_id_by_phone_number(phone_number)
	local user = m_user:get_all_user_by_phone_number(phone_number)
	if false == user then
		return false
	end
	local user_id = account_service:filter_user_id(user)
	return user_id
end

function account_service:set_default_change_password_verified(phone_number)
	local n, err = m_user:set_default_change_password_verified(phone_number)
	if nil == n then
		return false, err
	end
	return true, nil
end

function account_service:update_validate_status_and_login(phone_number, key, access_token)
	local n, err = m_user:update_validate_status_and_login(phone_number, key, access_token)
	if nil == n then 
		return false, err
	end
	return true, nil
end

function account_service:access_token_expires(signin_time)
	local has_been = ngx.time() - signin_time
	if has_been > const.token_expires_time then
		return true
	end
	return false
end

function account_service:is_logined(user_id, access_token)
	user_id = helper.to_object_id(user_id)
	local user = m_user:get_all_user_by_user_id(user_id)
	if nil == user then 
		return nil
	end
	if true == account_service:access_token_expires(user.signin_time) then 
		return false
	end
	if user.access_token ~= access_token then
		return false
	end
	return true
end

function account_service:validate_sms(phone_number, validate_code)
	local user = m_user:get_all_user_by_phone_number(phone_number)
	if false == user then
		return nil
	end
	if helper.atoi(user.validate_code) ~= helper.atoi(validate_code) then
		return false
	end
	return true
end

function account_service:register(user)
	local n, err = m_user:upsert_user(user)
	if nil == n then 
		return false, err
	end
	return true, err
end

function account_service:get_random_question(questions_init)
	local questions = {}
	local count = 0
	for class_name,  class_number in pairs(questions_init) do
		m_question:select_collection(class_name)
		local questions_cursor = m_question:get_all_question()
		if not questions_cursor then
			local err = "查询数据库出错"
			return false, err
		end
		local dealed_questions = {}
		for key, value in questions_cursor:pairs() do
			dealed_questions[key] = value
			count = count + 1
		end
		questions[class_name] = {}
		local i = 1;
		local loop_time = 0;
		if "basic_info" == class_name then
			questions[class_name][i] = {}
			questions[class_name][i]["problem_id"] = "570cfa06b2c2e07d9f1d69f7"
			questions[class_name][i]["problem_content"] = "用一段话介绍自己"
			questions[class_name][i]["problem_order"] = i
			i = i + 1
		end
		repeat
			local index = math.random(1, count)
			if dealed_questions[index] ~= nil and dealed_questions[index]["_id"]:tostring() ~= "570cfa06b2c2e07d9f1d69f7" then
				dealed_questions[index]["available"] = nil
				questions[class_name][i] = {}
				questions[class_name][i]["problem_id"] = dealed_questions[index]["_id"]:tostring()
				questions[class_name][i]["problem_content"] = dealed_questions[index]["question_content"]
				questions[class_name][i]["problem_order"] = i
				dealed_questions[index] = nil
				i = i + 1
			end
			loop_time = loop_time + 1
		until i > class_number or loop_time == 50
	end
	return questions, nil
end	

function account_service:new()
	return setmetatable({}, {__index = self})
end

return account_service