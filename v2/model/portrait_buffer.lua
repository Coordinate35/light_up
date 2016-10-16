local const = loadfile(ngx.var.root .. "/v2/config/constants.lua")()
local portrait_buffer = loadfile(ngx.var.root .. "/v2/core/model.lua")():new()

portrait_buffer._VERSION = "0.0.1"

function portrait_buffer:get_user_buffer(user_id)
	local buffer = self.collection:find_one({
			["user_id"] = user_id
		}
	)
	return buffer
end

function portrait_buffer:delete_item(user_id)
	local n, err = self.collection:delete({
			["user_id"] = user_id
		}
	)
	return n, err
end

function portrait_buffer:add_item(storing_info)
	local n, err = self.collection:update({
			["user_id"] = storing_info.user_id
		}, {
			["$set"] = storing_info
		}, 1, 0, 1
	)
	return n, err
end

function portrait_buffer:select_collection()
	self.db = self.conn:new_db_handle(ngx.var.db_name)
	if nil == self.db then 
		return false
	end
	self.collection = self.db:get_col("portrait_buffer")
	if nil == self.collection then
		return false
	end
	return true
end

function portrait_buffer:new()
	if false == self:connect_database() then
        return false
    end
    if false == self:select_collection() then
    	return false
    end
    return setmetatable({}, {__index = self})
end

return portrait_buffer