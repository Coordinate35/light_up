local media = loadfile(ngx.var.root .. "/v2/core/model.lua")():new()

media._VERSION = "0.0.1"

function media:get_item_by_sex_and_class(sex, class)
	local cursor = self.collection:find({
			["available"] = true,
			["class"] = class,
			["sex"] = sex
		}
	)
	return cursor
end

function media:get_item_by_user_id_and_class(user_id, class)
	local item = self.collection:find_one({
			["owner_id"] = user_id,
			["class"] = class,
			["available"] = true
		}
	)
	return item
end

function media:disable_item_by_user_id_and_class(user_id, class)
	local n, err = self.collection:update({
			["owner_id"] = user_id,
			["class"] = class
		}, {
			["$set"] = {
				["available"] = false
			}
		}, 0, 1, 1
	)
	return n, err
end

function media:set_unavailable_by_user_id_and_class(user_id, class)
	local n, err = self.collection:update({
			["owner_id"] = user_id,
			["class"] = class
		}, {
			["$set"] = {
				["available"] = false
			}
		}, 0, 0, 1
	)
	return n, err
end

function media:insert_item(object_to_store)
	local n, err = self.collection:insert({
			object_to_store
		}
	)
	return n, err
end

return media