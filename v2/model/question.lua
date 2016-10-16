local question = loadfile(ngx.var.root .. "/v2/core/model.lua")():new()
question._VERSION = "0.0.1"

function question:get_question_by_id(question_id)
	local question_content = self.collection:find_one({
			["_id"] = question_id,
			["available"] = true
		}
	)
	return question_content
end

function question:get_all_question()
	local target_question_cursor = self.collection:find({
			["available"] = true
		}
	)
	-- print(self.collection:count({["available"] = true}))
	return target_question_cursor
end

function question:select_collection(class_name)
	self.db = self.conn:new_db_handle(ngx.var.db_name)
	if nil == self.db then 
		return false
	end
	self.collection = self.db:get_col(class_name)
	if nil == self.collection then
		return false
	end
	return true
end

return question