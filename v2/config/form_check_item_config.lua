local form_check_item_config = {}

form_check_item_config.order = {
	["field"] = "order",
	["label"] = "灯的序号",
	["rules"] = "required|greater_than_equal_to[1]|less_than_equal_to[3]"
}

form_check_item_config.light_status = {
	["field"] = "light_status",
	["label"] = "灯的状态",
	["rules"] = "required|greater_than_equal_to[0]|less_than_equal_to[1]"
}

form_check_item_config.love_sex = {
	["field"] = "love_sex",
	["label"] = "性取向",
	["rules"] = "required|in_love_sex"
}

form_check_item_config.media_class = {
	["field"] = "class",
	["label"] = "媒体文件对应的资料阶段",
	["rules"] = "required|in_media_class"
}

form_check_item_config.question_id = {
	["field"] = "question_id",
	["label"] = "问题的id",
	["rules"] = "required|exact_length[24]"
}

form_check_item_config.question_order = {
	["field"] = "question_order",
	["label"] = "问题的序号",
	["rules"] = "required|is_number"
}

form_check_item_config.file_type = {
	["field"] = "file_type",
	["label"] = "上传媒体文件的类型",
	["rules"] = "required|is_file_type"
}

form_check_item_config.audio_class = {
	["field"] = "audio_class",
	["label"] = "音频文件所对应的阶段",
	["rules"] = "required|in_audio_class"
}

form_check_item_config.video_class = {
	["field"] = "video_class",
	["label"] = "视频文件所对应的阶段",
	["rules"] = "required|in_video_class"
}

form_check_item_config.question_arr = {
	["field"] = "question_arr",
	["label"] = "音频类型阶段包含的问题",
	["rules"] = "required|is_question_arr"
}

form_check_item_config.questions = {
	["field"] = "questions",
	["label"] = "视频类型阶段包含的问题",
	["rules"] = "required|is_questions"
}

form_check_item_config.save_key = {
	["field"] = "save_key",
	["label"] = "头像云端保存的路径",
	["rules"] = "required|max_length[255]|min_length[1]"
}

form_check_item_config.bucket = {
	["field"] = "bucket",
	["label"] = "资源存放的空间名",
	["rules"] = "required|max_length[20]|min_length[2]"
}

form_check_item_config.expiration = {
	["field"] = "expiration",
	["label"] = "过期时间",
	["rules"] = "required|is_number"
}

form_check_item_config.device_token = {
	["field"] = "device_token",
	["label"] = "用户的设备id",
	["rules"] = "required"
}

form_check_item_config.target_id = {
	["field"] = "target_id",
	["label"] = "目标用户的id",
	["rules"] = "required|exact_length[24]"
}

form_check_item_config.all_class = {
	["field"] = "class",
	["label"] = "媒体文件类型",
	["rules"] = "required|in_all_class"
}

form_check_item_config.login_type = {
	["field"] = "login_type",
	["label"] = "登陆类型",
	["rules"] = "required|is_login_type"
}

form_check_item_config.password = {
	["field"] = "password",
	["label"] = "密码",
	["rules"] = "required|min_length[6]|max_length[30]"
}

form_check_item_config.register_phone_number = {
	["field"] = "phone_number",
	["label"] = "手机号码",
	["rules"] = "required|is_unique[user.phone_number]|exact_length[11]"
}

form_check_item_config.common_phone_number = {
	["field"] = "phone_number",
	["label"] = "手机号码",
	["rules"] = "required|exact_length[11]"
}

form_check_item_config.validate_code = {
	["field"] = "validate_code",
	["label"] = "验证码",
	["rules"] = "required|greater_than_equal_to[100000]|less_than_equal_to[999999]"
}

form_check_item_config.validate_type = {
	["field"] = "validate_type",
	["label"] = "验证类型",
	["rules"] = "required|in_validate_type"
}

form_check_item_config.user_id = {
	["field"] = "user_id",
	["label"] = "用户的id",
	["rules"] = "required|exact_length[24]"
}

form_check_item_config.access_token = {
	["field"] = "access_token",
	["label"] = "用户的令牌",
	["rules"] = "required|exact_length[32]"
}

form_check_item_config.personal_info = {
	["field"] = "personal_info",
	["label"] = "用户的个人信息",
	["rules"] = "required|is_personal_info"
}

form_check_item_config.portrait = {
	["field"] = "portrait",
	["label"] = "用户头像地址",
	["rules"] = "required|min_length[4]|max_length[250]"
}

form_check_item_config.change_nickname = {
	["field"] = "nickname",
	["label"] = "用户昵称",
	["rules"] = "required|min_length[1]|max_length[30]|is_unique[user.nickname]"
}

form_check_item_config.nickname = {
	["field"] = "nickname",
	["label"] = "用户昵称",
	["rules"] = "required|min_length[1]|max_length[30]"
}

form_check_item_config.weibo_nickname = {
	["field"] = "weibo_nickname",
	["label"] = "用户的微博昵称",
	["rules"] = "required|min_length[1]|max_length[30]"
}

form_check_item_config.wechat_nickname = {
	["field"] = "wechat_nickname",
	["label"] = "用户微信昵称",
	["rules"] = "required|min_length[1]|max_length[30]"
}

form_check_item_config.sex = {
	["field"] = "sex",
	["label"] = "用户的性别",
	["rules"] = "required|is_sex"
}

form_check_item_config.love_sex = {
	["field"] = "love_sex",
	["label"] = "用户的性取向",
	["rules"] = "required|is_love_sex"
}

form_check_item_config.birthday = {
	["field"] = "birthday",
	["label"] = "用户的生日",
	["rules"] = "required|is_number"
}

form_check_item_config.location = {
	["field"] = "location",
	["label"] = "用户的地址",
	["rules"] = "required"
}

return form_check_item_config