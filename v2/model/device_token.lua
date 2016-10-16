local const = loadfile(ngx.var.root .. "/v2/config/constants.lua")()
local device_token = loadfile(ngx.var.root .. "/v2/core/model.lua")():new()

device_token._VERSION = "0.0.1"

function device_token:insert_item(user_id, device_token, create_time)
	local n, err = self.collection:insert({
		{
			["user_id"] = user_id,
			["device_token"] = device_token,
			["create_time"] = create_time
		}
	})
	return n, err
end

function device_token:select_collection()
	self.db = self.conn:new_db_handle(ngx.var.db_name)
	if nil == self.db then 
		return false
	end
	self.collection = self.db:get_col("device_token")
	if nil == self.collection then
		return false
	end
	return true
end

function device_token:new()
	if false == self:connect_database() then
        return false
    end
    if false == self:select_collection() then
    	return false
    end
    return setmetatable({}, {__index = self})
end

return device_token