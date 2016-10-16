var Hy = require('../utils/utils.js');
var VM = require('../utils/vm.js');
var Reminder = require('./reminder.js');
var alert = new Reminder();
var $avatar, $username, $sex, $age, $aptitude, $location, $basicLight, $expLight, $valueLight;
var user_id = ""
var initFlag = false;
$(window).on('load', function() {
	init();
	$('.edit.btn').on('tap', function() {
		Hy.requestHybrid({
			type: "jump",
			args: {
				page: "update_profile"
			}
		})
	})

	$('.basic.item').on('tap', function() {
		var page = info.data.basic_info_complete ? "play_audio" : "audio_question_list";
		Hy.requestHybrid({
			type: "jump",
			args: {
				page: page,
				type: "basic",
				user_id: user_id
			}
		})
	})
	$('.experience.item').on('tap', function() {
		var page = info.data.emotion_experience_complete ? "play_video" : "video_question_list"
		Hy.requestHybrid({
			type: "jump",
			args: {
				page: page,
				type: "experience",
				user_id: user_id
			}
		})
	})
	$('.value.item').on('tap', function() {
		var page = info.data.value_concept_complete ? "play_video" : "video_question_list"
		Hy.requestHybrid({
			type: "jump",
			args: {
				page: page,
				type: "value",
				user_id: user_id
			}
		})
	})
})

function init() {
	$avatar = $('.avatar');
	$username = $('.username span');
	$sex = $('.username i')
	$age = $('.age');
	$aptitude = $('.aptitude');
	$location = $('.location')
	$basicLight = $('.basic .lightup');
	$expLight = $('.experience .lightup');
	$valueLight = $('.value .lightup');
	alert.init('');
	window.info = new VM({
		data: {
			portrait: {
				value: '',
				$el: $avatar,
				type: 'src'
			},
			nickname: {
				value: '',
				$el: $username,
				type: 'text'
			},
			sex: {
				value: '',
				$el: $sex,
				type: 'class'
			},
			love_sex: {
				value: '',
				$el: $aptitude,
				type: 'text'
			},
			location: {
				value: '',
				$el: $location,
				type: 'text'
			},
			age: {
				value: 0,
				$el: $age,
				type: 'text'
			},
			basic_info_light_number: {
				value: 0,
				$el: $basicLight,
				type: 'text'
			},
			basic_info_complete : {
				value: false
			},
			emotion_experience_light_number: {
				value: 0,
				$el: $expLight,
				type: 'text'
			},
			emotion_experience_complete : {
				value: false
			},
			value_concept_light_number: {
				value: 0,
				$el: $valueLight,
				type: 'text'
			},
			value_concept_complete : {
				value: false
			}
		}
	});

	console.log('init end')

	Hy.requestHybrid({
		type: 'getAccessToken',
		call: function(data) {
			user_id = data.user_id;
			var access_token = data.access_token;
			$.ajax({
				url: '/v1/account/get_user_info',
				type: 'POST',
				data: {
					user_id: user_id,
					access_token: access_token,
					target_id: user_id
				},
				timeout: 5000,
				dataType: "json"
			}).done(function(res) {
				var sex = res.data.sex;
				var loveSex = res.data.love_sex;
				if (loveSex === 'male' || loveSex === 'female' || loveSex === 'both') {
					if (loveSex === 'both') {
						res.data.love_sex = "双性恋";
					} else if (sex === loveSex) {
						res.data.love_sex = "同性恋";
					} else {
						res.data.love_sex = "异性恋";
					}
				}
				for (key in info.data) {
					info.data[key] = res.data[key];
				}
				$('.mask').hide();
				initFlag = true;
			}).fail(function() {
				console.log('fail')
				$('.loading-container').hide();
				alert.show('加载失败。请重试', 2000);
				initFlag = true;
			});
		},
		args: {}
	})
}

window.willappear = function() {
	if (!initFlag) {
		return;
	}
	Hy.requestHybrid({
		type: 'getAccessToken',
		call: function(data) {
			user_id = data.user_id;
			var access_token = data.access_token;
			$.ajax({
				url: '/v1/account/get_user_info',
				type: 'POST',
				data: {
					user_id: user_id,
					access_token: access_token,
					target_id: user_id
				},
				dataType: "json"
			}).done(function(res) {
				var sex = res.data.sex;
				var loveSex = res.data.love_sex;
				if (loveSex === 'male' || loveSex === 'female' || loveSex === 'both') {
					if (loveSex === 'both') {
						res.data.love_sex = "双性恋";
					} else if (sex === loveSex) {
						res.data.love_sex = "同性恋";
					} else {
						res.data.love_sex = "异性恋";
					}
				}
				for (key in info.data) {
					info.data[key] = res.data[key];
				}
				$('.mask').hide();
			}).fail(function() {
				console.log('fail')
				$('.loading-container').hide();
				alert.show('加载失败。请重试', 2000);
			});
		},
		args: {}
	})
}