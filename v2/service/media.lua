local media_service = {}

function media_service:delete_media_by_user_id_and_class(file_type, user_id, class)
	local m_media = loadfile(ngx.var.root .. "/v2/model/" .. file_type .. ".lua")():new()
	local n, err = m_media:disable_item_by_user_id_and_class(user_id, class)
	if not n then
		return false, err
	end
	return true, nil
end

function media_service:upsert_item(file_type, object_to_store)
	local m_media = loadfile(ngx.var.root .. "/v2/model/" .. file_type .. ".lua")():new()
	local n, err = m_media:set_unavailable_by_user_id_and_class(object_to_store.user_id, object_to_store.class)
	if not n then
		return false, err
	end
	local n, err = m_media:insert_item(object_to_store)
	if not n then
		return false, err
	end
	return true, nil
end

function media_service:new()
	return setmetatable({}, {__index = self})
end

return media_service