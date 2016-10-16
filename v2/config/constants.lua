local const = {}

const.one_day_second = 86400

const.user_collection = "user"

const.all_class = {
	{
		["class"] = "basic_info",
		["media_type"] = "audio",
		["order"] = 1
	},
	{
		["class"] = "emotion_experience",
		["media_type"] = "video",
		["order"] = 2
	},
	{
		["class"] = "value_concept",
		["media_type"] = "video",
		["order"] = 3
	}
}

const.questions_init = {
	["basic_info"] = 3, 
	["emotion_experience"] = 3, 
	["value_concept"] = 3
}

const.token_expires_time = 900
const.token_refreshable_time = 1296000

const.chech_segment_have_seen_base_time = -18000
const.segment_long = {25200, 25200, 36000}
const.allow_get_user_number_per_segment = 8
const.allow_get_user_number_for_uncomplete_media_user_per_day = 3
const.day_first_change_segment_second = 18000
const.last_day_lasy_change_segment_from_today  = 18000
const.last_light_order = 3

const.dev_upyun_domain = "http://devlightup.b0.upaiyun.com"
const.upyun_domain = const.dev_upyun_domain
const.upyun_form_key = "Guess~"
const.upyun_video_bucket = "video"
const.upyun_audio_bucket = "audio"
const.upyun_protocol = "http://"
const.day_light_up_number_for_uncomplete_user = 2

return const