local form_check_config = {}

form_check_config.register = "register_phone_number"

form_check_config.validate_sms = "common_phone_number&validate_code&validate_type"

form_check_config.change_personal_info = "user_id&access_token&personal_info"

form_check_config.personal_info = "common_phone_number|portrait|change_nickname|weibo_nickname|wechat_nickname|sex|love_sex|birthday|location"

form_check_config.refresh_access_token = "user_id&access_token"

form_check_config.login = "common_phone_number&login_type&(password|access_token)"

form_check_config.change_password = "common_phone_number&password"

form_check_config.change_password_request = "common_phone_number"

form_check_config.get_account_questions = "user_id&access_token&all_class"

form_check_config.get_user_info = "user_id&access_token&target_id"

form_check_config.refresh_device_token_lib = "user_id&access_token&device_token"

form_check_config.upload_portrait_request = "user_id&access_token&save_key&bucket&expiration"

form_check_config.upload_portrait_confirm = "user_id&access_token"

form_check_config.upload_media = "file_type&user_id&access_token&sex&((audio_class&question_arr)|(video_class&save_key&questions))"

form_check_config.question_arr_element = "save_key&question_id&question_order"

form_check_config.questions_element = "question_id&question_order"

form_check_config.delete_media = "user_id&access_token&file_type&media_class"

form_check_config.get_media = "user_id&access_token&target_id&media_class&file_type"

form_check_config.get_user_ids_by_love_sex = "user_id&access_token&love_sex"

form_check_config.get_message = "user_id&access_token"

form_check_config.light_up = "user_id&access_token&target_id&order&light_status"

form_check_config.log_have_seen = "user_id&access_token&target_id"

return form_check_config