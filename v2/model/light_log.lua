local const = loadfile(ngx.var.root .. "/v2/config/constants.lua")()
local light_log = loadfile(ngx.var.root .. "/v2/core/model.lua")():new()

light_log._VERSION = "0.0.1"

function light_log:light_up(user_id, target_id, order, available, time)
	local n, err = self.collection:insert({{
			["user_id"] = user_id,
			["target_id"] = target_id,
			["order"] = order,
			["time"] = time,
			["available"] = available
		}}
	)
	return n, err
end

function light_log:set_previous_light_unavailable(user_id, target_id, order)
	local n, err = self.collection:update({
			["user_id"] = user_id,
			["target_id"] = target_id,
			["order"] = order
		}, {
			["$set"] = {
				["available"] = false
			}
		}, 0, 1, 1
	)
	return n, err
end

function light_log:count_user_light_number_by_time_section(user_id, start_time, end_time)
	local n = self.collection:count({
			["user_id"] = user_id,
			["available"] = true,
			["time"] = {
				["$gt"] = start_time,
				["$lt"] = end_time,
			}
		}
	)
	return n
end

function light_log:get_user_last_light_been_light_log_cursor_from_time(user_id, from_time, order)
	local cursor = self.collection:find({
			["target_id"] = user_id,
			["time"] = {
				["$gt"] = from_time
			},
			["available]"] = true,
			["order"] = order
		}
	)
	return cursor
end

function light_log:count_user_light_user_number(user_id, target_id)
	local number = self.collection:count({
			["user_id"] = user_id,
			["target_id"] = target_id,
			["available"] = true
		}
	)
	return number
end

function light_log:count_by_order(user_id, order)
	local number = self.collection:count({
			["target_id"] = user_id,
			["available"] = true,
			["order"] = tostring(order)
		}
	)
	return number
end

function light_log:select_collection()
	self.db = self.conn:new_db_handle(ngx.var.db_name)
	if nil == self.db then 
		return false
	end
	self.collection = self.db:get_col("light_log")
	if nil == self.collection then
		return false
	end
	return true
end

function light_log:new()
	if false == self:connect_database() then
        return false
    end
    if false == self:select_collection() then
    	return false
    end
    return setmetatable({}, {__index = self})
end

return light_log