local const = loadfile(ngx.var.root .. "/v2/config/constants.lua")()
local user = loadfile(ngx.var.root .. "/v2/core/model.lua")():new()

user._VERSION = "0.0.1"

function user:set_change_password_unverified(phone_number, validate_code)
	local n , err = self.collection:update({
			["phone_number"] = phone_number
		}, {
			["$set"] = {
				["change_password_verified"] = false,
				["validate_code"] = validate_code
			}
		}, 0, 0, 1
	)
	return n, err
end

function user:change_personal_info(user_id, personal_info)
	local n, err = self.collection:update({
			["_id"] = user_id
		}, {
			["$set"] = personal_info
		}, 0, 0, 1
	)
	return n, err
end

function user:set_default_change_password_verified(phone_number)
	local n, err = self.collection:update({
			["phone_number"] = phone_number
		}, {
			["$set"] = {
				["change_password_verified"] = true
			}
		}, 1
	)
	return n, err
end

function user:update_validate_status_and_login(phone_number, key, access_token)
	local n, err = self.collection:update({
			["phone_number"] = phone_number
		}, {
			["$set"] = {
				[key] = true,
				["signin_time"] = ngx.time(),
				["access_token"] = access_token,
				["validate_code"] = -1
			}
		}, 1
	)
	return n, err
end

function user:upsert_user(user)
	local n, err = self.collection:update({
			["phone_number"] = user.phone_number
		}, user, 1, 0 ,1
	)
	return n, err
end

function user:get_all_user_by_user_id(user_id)
	local target_user = self.collection:find_one({
			["_id"] = user_id
		}
	)
	return target_user
end

function user:get_all_user_by_phone_number(phone_number)
	local target_user = self.collection:find_one({
			["phone_number"] = phone_number
		}
	)
	if nil == target_user then
		return false
	end
	return target_user
end

function user:get_user_by_user_id(user_id)
	local target_user = self.collection:find_one({
			["_id"] = user_id,
			["available"] = true
		}
	)
	return target_user
end

function user:get_user_by_phone_number(phone_number)
	local target_user = self.collection:find_one({
			["phone_number"] = phone_number,
			["available"] = true
		}
	)
	if nil == target_user then
		return false
	end
	return target_user
end

function user:get_user_by_nickname(nickname)
	local target_user = self.collection:find_one({
			["nickname"] = nickname,
			["available"] = true
		}
	)
	if nil == target_user then
		return false
	end
	return target_user
end

function user:get_collection()
	self.db = self.conn:new_db_handle(ngx.var.db_name)
	if nil == self.db then 
		return false
	end
	self.collection = self.db:get_col(const.user_collection)
	if nil == self.collection then
		return false
	end
	return true
end

function user:new()
	if false == self:connect_database() then
        return false
    end
    if false == self:get_collection() then
    	return false
    end
    return setmetatable({}, {__index = self})
end

return user