local video = loadfile(ngx.var.root .. "/v2/model/media.lua")():new()
video._VERSION = "0.0.1"

function video:count_by_class(user_id, class)
	local number = self.collection:count({
			["owner_id"] = user_id,
			["available"] = true,
			["class"] = class
		}
	)
	return number
end

function video:select_collection()
	self.db = self.conn:new_db_handle(ngx.var.db_name)
	if nil == self.db then 
		return false
	end
	self.collection = self.db:get_col("video")
	if nil == self.collection then
		return false
	end
	return true
end

function video:new()
	if false == self:connect_database() then
        return false
    end
    if false == self:select_collection() then
    	return false
    end
    return setmetatable({}, {__index = self})
end


return video