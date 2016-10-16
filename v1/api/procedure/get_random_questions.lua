local json = require("cjson")
local helper = loadfile(ngx.var.root .. "/v1/helpers/global_helper.lua")()
local const = loadfile(ngx.var.root .. "/v1/constants/constants.lua")()
local random = require("resty.random")
local http_response = loadfile(ngx.var.root .. "/v1/helpers/http_response.lua")()
dofile(ngx.var.root .. "/v1/helpers/table_util.lua")

ngx.req.read_body()
local args, err = ngx.req.get_post_args()
local form_check = loadfile(ngx.var.root .. "/v1/helpers/form_check.lua")()
local check_content = {
	"user_id", 
	"access_token",
	"class",
	"limit"
}

if not form_check.check_form(args, check_content) then
	http_response.response_bad_request()
end

args.user_id = helper.to_object_id(args.user_id)
args.limit = math.floor(tonumber(args.limit))
if not helper.is_logined(args.user_id, args.access_token) then 
	http_response.response_not_logined()
end


local conn = loadfile(ngx.var.root .. "/v1/helpers/mongo_connect.lua")()
local db = conn:new_db_handle(ngx.var.db_name)
local questions_collection = db:get_col(args.class)

local questions = questions_collection:find({
		["available"] = true
	}
)

if not questions then 
	http_response.response_server_error()
end

local dealed_questions = {}
for key, value in questions:pairs() do
	dealed_questions[key] = value
end

local count = questions_collection:count({
		["available"] = true
	}
)
local candidate = {["data"] = {}}
candidate["data"]["questions"] = {};
local i = 1;
local loop_time = 0;
repeat
	local index = math.random(1, count)
	if dealed_questions[i] ~= nil then 
		dealed_questions[i]["available"] = nil
		candidate["data"]["questions"][i] = {}
		candidate["data"]["questions"][i]["problem_id"] = dealed_questions[i]["_id"]:tostring()
		candidate["data"]["questions"][i]["problem_content"] = dealed_questions[i]["question_content"]
		dealed_questions[i] = nil
		i = i + 1
		print(i)
	end
	loop_time = loop_time + 1
	print(index)
until i > args.limit or loop_time == 10

http_response.response_success(json.encode(candidate))