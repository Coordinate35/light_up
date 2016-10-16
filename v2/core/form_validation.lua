local helper = loadfile(ngx.var.root .. "/v2/helper/global_helper.lua")()
local json = loadfile(ngx.var.root .. "/v2/core/json.lua")()
-- local form_check_item_config = loadfile(ngx.var.root .. "/v2/config/form_check_item_config.lua")()

local form_validation = {}

form_validation._VERSION = "0.0.1"

function form_validation.in_love_sex(data)
	local msg = "不合法"
	local all_love_sex = {"male", "female", "both"}
	for key, value in pairs(all_love_sex) do
		if value == data then
			return true, nil
		end
	end
	return false, msg
end

function form_validation.in_media_class(data)
	local msg = "不合法"
	local all_media_class = {"basic_info", "emotion_experience", "value_concept"}
	for key, value in pairs(all_media_class) do
		if value == data then
			return true, nil
		end
	end
	return false, msg
end

function form_validation.is_question_arr(data)
	local msg
	local question_arr = json.decode(data)
	local form_check_config = loadfile(ngx.var.root .. "/v2/config/form_check_config.lua")()
	local check_item = form_check_config.question_arr_element
	for key, value in pairs(question_arr) do
		local result, err = form_validation.check(value, check_item)
		if false == result then
			return result, err
		end
	end
	return result, err
end

function form_validation.is_questions(data)
	local msg
	local questions = json.decode(data)
	local form_check_config = loadfile(ngx.var.root .. "/v2/config/form_check_config.lua")()
	local check_item = form_check_config.questions_element
	for key, value in pairs(questions) do
		local result, err = form_validation.check(questions, check_item)
		if false == result then
			return result, err
		end
	end
	return result, err
end

function form_validation.is_file_type(data)
	local msg = "不合法"
	local all_type = {"audio", "video"}
	for key, value in pairs(all_type) do
		if value == data then
			return true, nil
		end
	end
	return false, msg
end

function form_validation.in_audio_class(data)
	local msg = "不合法"
	local all_type = {"basic_info"}
	for key, value in pairs(all_type) do
		if value == data then
			return true, nil
		end
	end
	return false, msg
end

function form_validation.in_video_class(data)
	local msg = "不合法"
	local all_type = {"emotion_experience", "value_concept"}
	for key, value in pairs(all_type) do
		if value == data then
			return true, nil
		end
	end
	return false, msg
end

function form_validation.in_all_class(data)
	local msg = "不合法"
	local all_class = {"basic_info", "emotion_experience", "value_concept"}
	for key, value in pairs(all_class) do
		if value == data then
			return true, nil
		end
	end
	return false, msg
end

function form_validation.is_login_type(data)
	local msg = "不合法"
	local possible_login_type = {"password", "access_token"}
	for key, value in pairs(possible_login_type) do
		if value == data then
			return true, nil
		end
	end
	return false, msg
end

function form_validation.is_number(data)
	local msg
	if nil == helper.atoi(data) then
		msg = "不合法"
		return false, msg
	end
	return true, nil
end

function form_validation.is_love_sex(data)
	local msg
	local love_sex_set = {"male", "female", "both"}
	for key, value in pairs(love_sex_set) do
		if value == data then
			return true, nil
		end
	end
	msg = "不合法"
	return false, msg
end

function form_validation.is_sex(data)
	local msg
	local sex_set = {"male", "female"}
	for key, value in pairs(sex_set) do
		if value == data then
			return true, nil
		end
	end
	msg = "不合法"
	return false, msg
end

function form_validation.min_length(data, condition_param)
	local msg
	local min_length = helper.atoi(condition_param[1])
	if #data < min_length then
		msg = "不合法"
		return false, msg
	end
	return true, nil
end

function form_validation.max_length(data, condition_param)
	local msg
	local max_length = helper.atoi(condition_param[1])
	if #data > max_length then
		msg = "不合法"
		return false, msg
	end
	return true, nil
end

function form_validation.is_personal_info(data)
	local msg
	local personal_info = json.decode(data)
	local form_check_config = loadfile(ngx.var.root .. "/v2/config/form_check_config.lua")()
	local check_item = form_check_config.personal_info
	local result, err = form_validation.check(personal_info, check_item)
	return result, err
end

function form_validation.in_validate_type(data)
	local msg
	if "register" ~= data and "change_password" ~= data then
		msg = "不合法"
		return false, msg
	end
	return true, nil
end

function form_validation.greater_than_equal_to(data, condition_param)
	local msg
	local downlimit = math.floor(tonumber(condition_param[1]))
	data = helper.atoi(data)
	if nil == data then
		msg = "不是数字"
		return false, msg
	end
	if data < downlimit then
		msg = "不合法"
		return false, msg
	end
	return true, nil
end

function form_validation.less_than_equal_to(data, condition_param)
	local msg
	local uplimit = math.floor(tonumber(condition_param[1]))
	data = helper.atoi(data)
	if nil == data then
		msg = "不是数字"
		return false, msg
	end
	if data > uplimit then
		msg = "不合法"
		return false, msg
	end
	return true, nil
end

function form_validation.is_unique(data, condition_param)
	local collection = condition_param[1]
	local field = condition_param[2]
	local s_form_validation = loadfile(ngx.var.root .. "/v2/service/form_validation.lua")():new()
	local target = s_form_validation:get_by_collection_field(collection, field, data)
	if false ~= target then
		local msg = "已经存在"
		return false, msg
	end
	return true, nil
end

function form_validation.exact_length(data, condition_param)
	local length = condition_param[1]
	local msg = "的长度必须为" .. length
	if #data ~= helper.atoi(length) then 
		return false, msg
	end
	return true, nil
end

function form_validation.required(data)
	local msg = "是必须填的"
	if not data then
		return false, msg
	end
	return true, nil
end

function form_validation.check_one_condition(data, condition)
	local parentheses_start = string.find(condition, "%[")
	local parentheses_end = string.find(condition, "%]")
	if nil == parentheses_start or nil == parentheses_end then
	-- print(condition)
		local is_correct, err = form_validation[condition](data)
		if false == is_correct then 
			return false, err
		end
	else
		local func_name = string.sub(condition, 1, parentheses_start - 1)
		local condition_param = string.sub(condition, parentheses_start + 1, parentheses_end - 1)
		condition_param = helper.split(condition_param, "%.")
		local is_correct, err = form_validation[func_name](data, condition_param)
		if false == is_correct then 
			return false, err
		end
	end
	return true, nil
end

function form_validation.check_one_item(data, conditions)
	local rules = helper.split(conditions.rules, '|')
	for key, value in pairs(rules) do 
		local is_correct, err = form_validation.check_one_condition(data, value)
		if false == is_correct then
			err = conditions.label .. err
			return false, err
		end
	end
	return true, nil
end

function form_validation.logic_and(param1, param2)
	return param1 and param2
end

function form_validation.logic_or(param1, param2)
	return param1 or param2
end

function form_validation.calculate(param1, param2, operator)
	local operator_function = {
		["|"] = form_validation.logic_or,
		["&"] = form_validation.logic_and
	}
	return operator_function[operator](param1, param2)
end

function form_validation.check(params, check_content)
	local form_check_item_config = loadfile(ngx.var.root .. "/v2/config/form_check_item_config.lua")()
	local params_stack = {}
	local operator_stack = {}
	local params_stack_pointer = 1
	local operator_stack_pointer = 1
	local operator = {
		[")"] = 1,
		["|"] = 2,
		["&"] = 3,
		["("] = 4
	}
	local total_err = ""
	local i = 1
	local check_content_length = #check_content
	local loop_time1 = 50
	while i <= check_content_length and loop_time1 > 0 do
		loop_time1 = loop_time1 - 1
		local j = i
		local loop_time2 = 50
		while nil ~= string.sub(check_content, j, j) and nil == operator[string.sub(check_content, j, j)] and loop_time2 > 0 do
			j = j + 1
			loop_time2 = loop_time2 - 1
		end
		local char_j = string.sub(check_content, j, j)
		if j ~= i then
			j = j - 1
			local param_name = string.sub(check_content, i, j)
			local item_condition = form_check_item_config[param_name]
			local is_success, err = form_validation.check_one_item(params[item_condition.field], item_condition)
			if false == is_success then
				total_err = total_err .. err .. "\n"
			end
			params_stack[params_stack_pointer] = is_success
			params_stack_pointer = params_stack_pointer + 1
		else
			if 1 ~= operator_stack_pointer then
				local loop_time3 = 50
				while operator_stack[operator_stack_pointer - 1] ~= "(" and loop_time3 > 0 and operator[operator_stack[operator_stack_pointer - 1]] > operator[char_j] do
					loop_time3 = loop_time3 - 1
					local param1 = params_stack[params_stack_pointer - 1]
					local param2 = params_stack[params_stack_pointer - 2]
					local top_operator = operator_stack[operator_stack_pointer - 1]
					params_stack[params_stack_pointer - 2] = form_validation.calculate(param1, parma2, top_operator)
					params_stack_pointer = params_stack_pointer - 1
					operator_stack_pointer = operator_stack_pointer - 1
				end
			end
			if ")" == char_j then 
				operator_stack_pointer = operator_stack_pointer - 1
			else
				operator_stack[operator_stack_pointer] = char_j
				operator_stack_pointer = operator_stack_pointer + 1
			end
		end
		i = j + 1
	end
	local loop_time4 = 50
	while loop_time4 > 0 and operator_stack_pointer ~= 1 and params_stack_pointer ~= 2 do
		loop_time4 = loop_time4 - 1
		local param1 = params_stack[params_stack_pointer - 1]
		local param2 = params_stack[params_stack_pointer - 2]
		local top_operator = operator_stack[operator_stack_pointer - 1]
		params_stack[params_stack_pointer - 2] = form_validation.calculate(param1, param2, top_operator)
		params_stack_pointer = params_stack_pointer - 1
		operator_stack_pointer = operator_stack_pointer - 1
	end
	return params_stack[1], total_err
end

return form_validation