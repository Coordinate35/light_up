local output = loadfile(ngx.var.root .. "/v2/core/output.lua")()
local helper = loadfile(ngx.var.root .. "/v2/helper/global_helper.lua")()
local const = loadfile(ngx.var.root .. "/v2/config/constants.lua")()
local zh_lang = loadfile(ngx.var.root .. "/v2/lang/chinese.lua")()
local user = {}

function user:upload_portrait_confirm(args)
	local user_id = helper.to_object_id(args.user_id)
	self.s_account = loadfile(ngx.var.root .. "/v2/service/account.lua")():new()
	local n, err = self.s_account:update_portrait(user_id)
	if not n then
		output.server_error("", err)
	end

	local response = {
		["status"] = zh_lang.update_portrait_successfully,
		["data"] = {}
	}
	output.success(response)
end

function user:upload_portrait_request(args)
	args.user_id = helper.to_object_id(args.user_id)
	args.access_token = nil
	self.s_account = loadfile(ngx.var.root .. "/v2/service/account.lua")():new()
	local n, err = self.s_account:add_portrait_buffer(args)
	if not n then
		output.server_error("", err)
	end
	
	local upyun_lib = loadfile(ngx.var.root .. "/v2/library/upyun.lua")():new(const.upyun_form_key)
	local policy = upyun_lib:generate_policy(args.bucket, args.expiration, args.save_key)
	local signature = upyun_lib:generate_signature(policy)
	local response = {
		["data"] = {
			["policy"] = policy,
			["signature"] = signature
		}
	}
	output.success(response)
end

function user:refresh_device_token_lib(args)
	local user_id = helper.to_object_id(args.user_id)
	local device_token = args.device_token
	self.s_account = loadfile(ngx.var.root .. "/v2/service/account.lua")():new()
	local is_success, err = self.s_account:refresh_device_token(user_id, device_token)
	if false == is_success then
		output.server_error("", err)
	end
	local response = {
		["status"] = zh_lang.update_device_token_successfully,
		["data"] = {}
	}
	output.success(response)
end

function user:get_user_info(args)
	local user_id = helper.to_object_id(args.user_id)
	local target_id = helper.to_object_id(args.target_id)
	self.s_account = loadfile(ngx.var.root .. "/v2/service/account.lua")():new()
	local target_user, err = self.s_account:get_user_info(target_id)
	if false == target_user then
		output.server_error("", err)
	end

	local response = {
		["status"] = zh_lang.get_user_info_successfully,
		["data"] = target_user
	}
	output.success(response)
end

function user:get_account_questions(args)
	local user_id = helper.to_object_id(args.user_id)
	local class = args.class
	self.s_account = loadfile(ngx.var.root .. "/v2/service/account.lua")():new()
	local questions = self.s_account:get_account_questions(user_id, class)
	if false == questions then
		output.server_error("", "")
	end

	local response = {}
	response.status = zh_lang.get_account_questions_successfully
	response.data = {
		["questions"] = questions
	}
	output.success(response)
end

function user:change_password_request(args)
	local phone_number = args.phone_number
	local validate_code = helper.generate_validate_code()

	self.s_account = loadfile(ngx.var.root .. "/v2/service/account.lua")():new()
	local is_success, err = self.s_account:change_password_prepare(phone_number, validate_code)
	if false == is_success then
		output.server_error("", err)
	end

	helper.send_validate_code(args.phone_number, validate_code)

	local response = {}
	response.status = zh_lang.sms_sent_successfully
	response.data = {}
	output.success(response)
end

function user:change_password(args)
	local personal_info = {
		["salt"] = helper.generate_salt(),
		["change_password_verified"] = false
	}
	personal_info.password = helper.crypt(args.password, personal_info.salt)
	self.s_account = loadfile(ngx.var.root .. "/v2/service/account.lua")():new()
	local user_id = self.s_account:get_user_id_by_phone_number(args.phone_number)
	if false == user_id then
		local err = "database error"
		output.server_error("", err)
	end
	local is_success, err = self.s_account:change_personal_info(helper.to_object_id(user_id), personal_info)
	if false == is_success then
		output.server_error("", err)
	end
	local response = {
		["status"] = zh_lang.change_password_successfully,
		["data"] = {}
	}
	output.success(response)
end

function user:login(args)
	self.s_account = loadfile(ngx.var.root .. "/v2/service/account.lua")():new()
	local user, err = self.s_account:refresh_access_token_get_user_info(args.phone_number)
	if false == user then
		output.server_error("", err)
	end
	local response = {
		["status"] = zh_lang.login_successfully,
		["data"] = user
	}
	output.success(response)
end

function user:refresh_access_token(args)
	local user_id = helper.to_object_id(args.user_id)
	self.s_account = loadfile(ngx.var.root .. "/v2/service/account.lua")():new()
	local access_token, err = self.s_account:refresh_access_token(user_id)
	if false == access_token then
		output.server_error("", err)
	end
	local response = {
		["status"] = zh_lang.refresh_access_token_successfully,
		["data"] = {
			["access_token"] = access_token
		}
	}
	output.success(response)
end

function user:change_personal_info(args)
	local user_id = helper.to_object_id(args.user_id)
	local json = loadfile(ngx.var.root .. "/v2/core/json.lua")()
	local personal_info = json.decode(args.personal_info)
	personal_info.available = true
	self.s_account = loadfile(ngx.var.root .. "/v2/service/account.lua")():new()
	local is_success, err = self.s_account:change_personal_info(user_id, personal_info)
	if false == is_success then
		output.server_error("", err)
	end
	local response = {
		["status"] = zh_lang.change_personal_info_successfully,
		["data"] = {}
	}
	output.success(response)
end

function user:update_validate_status_and_login(phone_number, key)
	local access_token = helper.generate_access_token()
	self.s_account = loadfile(ngx.var.root .. "/v2/service/account.lua")():new()
	local is_success, err = self.s_account:update_validate_status_and_login(phone_number, key, access_token)
	if false == is_success then 
		output.server_error("", err)
	end
	local user_id = self.s_account:get_user_id_by_phone_number(phone_number)
	if false == user_id then
		output.server_error("", err)
	end
	return user_id, access_token
end

function user:pass_validate_sms_change_password(args)
	local key = "change_password_verified"
	local user_id, access_token = self:update_validate_status_and_login(args.phone_number, key)
	local response = {
		["data"] = {
			["user_id"] = user_id,
			["access_token"] = access_token
		}
	}
	output.success(response)
end

function user:pass_validate_sms_register(args)
	local key = "register_verified"
	local user_id, access_token = self:update_validate_status_and_login(args.phone_number, key)
	local is_success, err = self.s_account:set_default_change_password_verified(args.phone_number)
	if false == is_success then
		output.server_error(", err")
	end
	local response = {
		["data"] = {
			["user_id"] = user_id,
			["access_token"] = access_token
		}
	}
	output.success(response)
end

function user:register(args)
	local validate_code = helper.generate_validate_code()
	local salt = helper.generate_salt()
	local user = {
		["portrait"] = "",
		["phone_number"] = args.phone_number,
		["salt"] = salt,
		["password"] = "",
		["access_token"] = "",
		-- ["device_token"] = "",
		["nickname"] = "",
		["weibo_nickname"] = "",
		["wechat_nickname"] = "",
		["weibo_uid"] = "",
		["wechat_uid"] = "",
    	["wechat_ID"] = "",
		["sex"] = "",
		["love_sex"] = "",
		["birthday"] = "",
		["location"] = "",
		["register_verified"] = false,
		["change_password_verified"] = false,
		["signin_ip"] = "",
		["signup_ip"] = "",
		["signin_time"] = "",
		["signup_time"] = ngx.time(),
		["validate_code"] = validate_code,
		["questions"] = {},
		["available"] = false
	}
	local s_account = loadfile(ngx.var.root .. "/v2/service/account.lua")():new()
	local questions, err = s_account:get_random_question(const.questions_init)
	if false == questions then
		output.server_error("", err)
	end
	user.questions = questions
	local is_success, err = s_account:register(user)
	if false == is_success then
		output.server_error("", err)
	end
	helper.send_validate_code(args.phone_number, validate_code)

	local response = {}
	response.status = zh_lang.register_success
	response.data = {}
	output.success(response)
end

function user:new()
	return setmetatable({}, {__index = self})
end

return user