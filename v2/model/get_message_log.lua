local get_message_log = loadfile(ngx.var.root .. "/v2/model/media.lua")():new()

get_message_log._VERSION = "0.0.1"

function get_message_log:get_log_cursor(user_id)
	local cursor = self.collection:find({
			["user_id"] = user_id
		}
	)
	return cursor
end

function get_message_log:select_collection()
	self.db = self.conn:new_db_handle(ngx.var.db_name)
	if nil == self.db then 
		return false
	end
	self.collection = self.db:get_col("get_message_log")
	if nil == self.collection then
		return false
	end
	return true
end

function get_message_log:new()
	if false == self:connect_database() then
        return false
    end
    if false == self:select_collection() then
    	return false
    end
    return setmetatable({}, {__index = self})
end


return get_message_log