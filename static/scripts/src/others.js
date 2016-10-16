var Hy = require('../utils/utils.js');
var VM = require('../utils/vm.js');
var Reminder = require('./reminder.js');
var Modal = require('../modules/modal.js');
var alert = new Reminder();
window.modal = new Modal();
var params = require('../utils/params.js')();
var $avatar, $username, $sex, $age, $aptitude, $location, $basicLight, $expLight, $valueLight;
var user_id = params['user_id'];
var wechat_id = '';

$(window).on('load', function() {
	init();
	$('.edit.btn').on('tap', function() {
		$('.overLayer .modal .wechat_ID').text(wechat_id);
		modal.show();
	})

	$('.basic.item').on('tap', function() {
		Hy.requestHybrid({
			type: "jump",
			args: {
				page: "play_audio",
				type: "basic",
				user_id: user_id
			}
		})
	})
	$('.experience.item').on('tap', function() {
		Hy.requestHybrid({
			type: "jump",
			args: {
				page: "play_video",
				type: "experience",
				user_id: user_id
			}
		})
	})
	$('.value.item').on('tap', function() {
		Hy.requestHybrid({
			type: "jump",
			args: {
				page: "play_video",
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
	modal.init('');
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
			emotion_experience_light_number: {
				value: 0,
				$el: $expLight,
				type: 'text'
			},
			value_concept_light_number: {
				value: 0,
				$el: $valueLight,
				type: 'text'
			}
		}
	});

	Hy.requestHybrid({
		type: 'getAccessToken',
		call: function(data) {
			var self_id = data.user_id;
			var access_token = data.access_token;
			$.ajax({
				url: '/v1/account/get_user_info',
				type: 'POST',
				data: {
					user_id: self_id,
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
				for (key in info.data) {
					info.data[key] = res.data[key];
				}
				wechat_id = res.data.wechat_ID;
				$('.mask').hide();
			}).fail(function() {
				$('.loading-container').hide();
				alert.show('加载失败。请重试', 2000);
			});
		},
		args: {}
	})
}