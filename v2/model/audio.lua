local audio = loadfile(ngx.var.root .. "/v2/model/media.lua")():new()
audio._VERSION = "0.0.1"

function audio:count_by_class(user_id, class)
	local number = self.collection:count({
			["owner_id"] = user_id,
			["available"] = true,
			["class"] = class
		}
	)
	return number
end

function audio:select_collection()
	self.db = self.conn:new_db_handle(ngx.var.db_name)
	if nil == self.db then 
		return false
	end
	self.collection = self.db:get_col("audio")
	if nil == self.collection then
		return false
	end
	return true
end

function audio:new()
	if false == self:connect_database() then
        return false
    end
    if false == self:select_collection() then
    	return false
    end
    return setmetatable({}, {__index = self})
end


return audio