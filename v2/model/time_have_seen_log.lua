local time_have_seen_log = loadfile(ngx.var.root .. "/v2/model/media.lua")():new()

time_have_seen_log._VERSION = "0.0.1"

function time_have_seen_log:log_have_seen(user_id, target_id, time)
	local is_success, err = self.collection:insert({{
			["user_id"] = user_id,
			["target_id"] = target_id,
			["time"] = time
		}}
	)
	return is_success, err
end

function time_have_seen_log:get_have_seen_users_cursor(user_id, from_time)
	local cursor = self.collection:find({
			["user_id"] = user_id,
			["time"] = {
				["$gt"] = from_time
			}
		}
	)
	return cursor
end

function time_have_seen_log:select_collection()
	self.db = self.conn:new_db_handle(ngx.var.db_name)
	if nil == self.db then 
		return false
	end
	self.collection = self.db:get_col("time_have_seen_log")
	if nil == self.collection then
		return false
	end
	return true
end

function time_have_seen_log:new()
	if false == self:connect_database() then
        return false
    end
    if false == self:select_collection() then
    	return false
    end
    return setmetatable({}, {__index = self})
end


return time_have_seen_log