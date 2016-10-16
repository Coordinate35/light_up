local const = {}

const.user_info_response = {
	"_id",
	"portrait",
	"phone_number",
	"access_token",
	"nickname",
	"weibo_nickname",
	"wechat_nickname",
	"weibo_uid",
	"wechat_uid",
	"wechat_ID",
	"sex",
	"love_sex",
	"birthday",
	"location"
}

const.token_expire_time = 900
const.token_refreshable_time = 1296000
const.warning_time = 648000
const.id_length = 24
const.upyun_form_key = "Guess~"
const.bucket_length_uplimit = 20
const.bucket_length_downlimit = 5
const.url_length_uplimit = 255
const.url_length_downlimit = 1
const.question_length_uplimit = 300
const.question_length_downlimit = 5
const.question_order_uplimit = 3
const.question_order_downlimit = 1
-- const.question_order_for_third_video_uplimit = 3
-- const.question_order_for_third_video_downlimit = 1
const.question_order_for_audio_uplimit = 3
const.question_order_for_audio_video_downlimit = 1
const.question_number = 3
const.possible_video_class = {"emotion_experience", "value_concept"}
const.possible_audio_class = {"basic_info"}
const.each_audio_menbers_in_arr = {"save_key", "question_id", "question_order"} 
const.possible_file_type = {"audio", "video"}
const.possible_block_class = {"basic_info", "emotion_experience", "value_concept"}
const.possible_love_sex = {"male", "female", "both"}
const.procedure_number = 3
const.one_year_have_second = 31536000
const.basic_info_order = 1
const.emotion_experience_order = 2
const.value_concept_order = 3
const.upyun_audio_bucket = "audio"
const.upyun_video_bucket = "video"
const.dev_upyun_domain = "devlightup.b0.upaiyun.com"
const.upyun_domain = const.dev_upyun_domain
const.last_light_order = "3"
const.return_number_when_getting_user_ids_by_sex = 5
const.day_second = 86400
const.half_day_second = 43200
const.day_five_oclock_second = 18000
const.day_nineteen_oclock_second = 68400
const.five_oclock = 5
const.twelve_oclock = 12
const.nineteen_oclock = 19
const.segment_number = 3
const.segment_define = {
	{
		["from"] = 0,
		['to'] = 36000
	},
	{
		["from"] = 36000,
		["to"] = 54000
	},
	{
		["from"] = 54000,
		["to"] = 86400
	}
}
const.part = {
	{
		["class"] = "basic_info",
		["media_type"] = "audio"
	},
	{
		["class"] = "emotion_experience",
		["media_type"] = "video"
	},
	{
		["class"] = "value_concept",
		["media_type"] = "video"
	}
}
const.light_up_uplimit_for_uncomplete_user = 2
const.allow_get_user_number_a_segment = 8
const.allow_get_user_number_a_day_for_complete = 3

return const