local account_service = {}

function account_service:get_by_collection_field(collection, field, data)
	local model = loadfile(ngx.var.root .. "/v2/model/" .. collection .. ".lua")()
	local model_obj = model:new()
	local target = model_obj["get_" .. collection .. "_by_" .. field](model_obj, data)
	return target
end

function account_service:new()
	return setmetatable({}, {__index = self})
end

return account_service