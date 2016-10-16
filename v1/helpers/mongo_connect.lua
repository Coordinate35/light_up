local helper = loadfile(ngx.var.root .. "/v1/helpers/global_helper.lua")()
local http_response = loadfile(ngx.var.root .. "/v1/helpers/http_response.lua")()

local p = "/usr/local/openresty/lualib/"
local m_package_path = package.path
package.path = string.format("%s?.lua;%s?/init.lua;%s",
    p, p, m_package_path)

local mongol = require("resty.mongol")
local conn = mongol:new()
local ok, err = conn:connect(ngx.var.mongo_host, ngx.var.mongo_port)
if not ok then
	http_response.response_server_error()
end

return conn