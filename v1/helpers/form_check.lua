local const = loadfile(ngx.var.root .. "/v1/constants/constants.lua")()
local json = require("cjson")

local _M = {}

function _M.light_status(light_status)
	if not light_status then 
		return false
	end
	if 0 ~= light_status and 1 ~= light_status then
		return false
	end
	return true
end

function _M.question_id(question_id)
	if not _M._id(question_id) then 
		return false
	end
	return true
end

function _M.order(order)
	if not order then 
		return false
	end
	order = math.floor(tonumber(order))
	if 0 > order or order > const.procedure_number then 
		return false
	end
	return true
end

function _M.sex(sex)
	if not sex then 
		return false
	end
	if "female" ~= sex and "male" ~= sex then
		return false
	end
	return true
end

function _M.love_sex(love_sex)
	if not love_sex then 
		return false
	end
	for key, value in pairs(const.possible_love_sex) do 
		if value == love_sex then 
			return true
		end
	end
	return true
end

function _M.limit(limit)
	if not limit then 
		return false
	end
	if const.question_number ~= math.floor(tonumber(limit)) then
		return false
	end
	return true
end

function _M.class(class)
	if not class then 
		return false
	end
	for key, value in pairs(const.possible_block_class) do
		if value == class then 
			return true
		end
	end
	return false
end

function _M.device_token(device_token)
	if not device_token then 
		return false
	end
	return true
end

function _M.target_id(target_id)
	if not _M._id(target_id) then
		return false
	end
	return true
end

function _M.user_id(user_id)
	if not _M._id(user_id) then
		return false
	end
	return true
end

function _M.file_id(file_id)
	if not file_id then 
		return false
	end
	if not _M._id(file_id) then 
		return false
	end
	return true
end

function _M.file_type(file_type)
	if not file_type then 
		return false
	end
	for key, value in pairs(const.possible_file_type) do
		if value == file_type then 
			return true
		end
	end
	return false
end

function _M._id(_id)
	if not _id then 
		return false
	end
	if math.floor(tonumber(const.id_length)) ~= #_id then
		return false
	end
	return true
end

function _M.audio_class(audio_class)
	if not audio_class then 
		return false
	end
	for key, value in pairs(const.possible_audio_class) do
		if value == audio_class then 
			return true
		end
	end
	return false
end

function _M.question_arr(audio_question_arr)
	if not audio_question_arr then 
		return false
	end
	audio_question_arr = json.decode(audio_question_arr)
	local audio_arr_menber = const.each_audio_menbers_in_arr
	for key, value in pairs(audio_question_arr) do 
		if not _M.check_form(value, const.each_audio_menbers_in_arr) then 
			return false
		end
	end
	return true
end

function _M.video_class(video_class)
	if not video_class then 
		return false
	end
	local pass = false
	for key, value in pairs(const.possible_video_class) do
		if value == video_class then 
			pass = true
		end
	end
	if not pass then 
		return false
	end
	return true
end

function _M.bucket(bucket)
	if not bucket then
		return false
	end
	if #bucket > const.bucket_length_uplimit or #bucket < const.bucket_length_downlimit then
		return false
	end
	return true
end

function _M.expiration(expiration)
	if not expiration then
		return false
	end
	if not tonumber(expiration) then 
		return false
	end
	return true
end

function _M.save_key(save_key)
	if not save_key then
		return false
	end
	if #save_key > const.url_length_uplimit or #save_key < const.url_length_downlimit then
		return false
	end
	return true
end

function _M.url(url)
	if not url then 
		return false
	end
	if #url > const.url_length_uplimit or #url < const.url_length_downlimit then
		return false
	end
	return true
end

function _M.questions(questions)
	if not questions then 
		return false
	end
	questions = json.decode(questions)
	for key, value in pairs(questions) do
		if not _M.question(value) then
			return false
		end
	end
	return true
end

function _M.question(question)
	if not question then 
		return false
	end
	if not _M.question_id(question.question_id) then
		print(question.question_id)
		return false
	end
	if not _M.question_order(question.question_order) then
		return false
	end
	return true
end

function _M.question_content(question_content)
	if not question_content then 
		return false
	end
	if #question_content > const.question_length_uplimit or #question_content < const.question_length_downlimit then
		return false
	end
	return true
end

function _M.question_order(question_order)
	if not question_order then 
		return false
	end
	if math.floor(tonumber(question_order)) > const.question_order_uplimit or math.floor(tonumber(question_order)) < const.question_order_downlimit then 
		return false
	end
	return true
end

function _M.personal_info(personal_info)
	if not personal_info then
		return false
	end
	return true
end

function _M.login_type(login_type)
	if not login_type then 
		return false
	end
	local possible_type = {"password", "access_token"}
	for k, v in pairs(possible_type) do
		if v == login_type then 
			return true
		end
	end
	return false
end

function _M.access_token(access_token)
	if access_token == nil then
		return false
	end
	return true
end

function _M.phone_number(phone_number)
	if not phone_number then 
		return false
	end
	local phone_number_length = #phone_number
	local expected_phone_number_length = math.floor(tonumber(ngx.var.phone_number_length))
	-- print (phone_number_length .. " " .. expected_phone_number_length)
	if phone_number_length ~= expected_phone_number_length then
		return false
	else
		return true
	end
end

function _M.password(password)
	if not password then 
		return false
	end
	local password_downlimit = math.floor(tonumber(ngx.var.password_downlimit))
	local password_uplimit = math.floor(tonumber(ngx.var.password_uplimit))
	local password_length = #password
	if password then
		if (password_downlimit <= password_length) and (password_uplimit >= password_length) then
			return true
		end
	end
	return false
end

function _M.validate_code(validate_code)
	if not validate_code then 
		return false
	end
	local validate_code_downlimit = math.floor(tonumber(ngx.var.validate_code_downlimit))
	local validate_code_uplimit = math.floor(tonumber(ngx.var.validate_code_uplimit))
	validate_code = math.floor(tonumber(validate_code))
	if validate_code_uplimit <= validate_code or validate_code <= validate_code_downlimit then
		return false
	end
	return true
end

function _M.validate_type(validate_type)
	if not validate_type then 
		return false
	end
	if validate_type == "register" or validate_type == "change_password" then
		return true
	else
		return false
	end
end

function _M.check_form(args, check_content)
	for key, value in pairs(check_content) do 
		if not _M[value](args[value]) then
			print(value)
			return false
		end
	end
	return true
end

return _M