local helper = loadfile(ngx.var.root .. "/v1/helpers/global_helper.lua")()
local const = loadfile(ngx.var.root .. "/v1/constants/constants.lua")()
local http_response = loadfile(ngx.var.root .. "/v1/helpers/http_response.lua")()
dofile(ngx.var.root .. "/v1/helpers/table_util.lua")
local json = require("cjson")

ngx.req.read_body()
local args, err = ngx.req.get_post_args()
local conn = loadfile(ngx.var.root .. '/v1/helpers/mongo_connect.lua')()
local db = conn:new_db_handle(ngx.var.db_name)
local user_collection = db:get_col("user")
local n, err = user_collection:delete({
		["phone_number"] = args.phone_number
	}, 0, 1
)
local response = {}
if nil == n then
	response.error = "remove account failed" 
elseif 0 == n then 
	response.error = "No such user"
else
	response.status = "remove account successfully"
end
response.data = {}
ngx.say(json.encode(response))
