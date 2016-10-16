var Jsbridge = require('./jsbridge');
var LightConfirm = require('./light_confirm');
var Reminder = require('./reminder');
var Audio = require('./audio');
var Video = require('./video');
var Countdown = require('./countdown');

var userInfo = require('../../tpl/index_user.tpl');

var user = {},
    stage = 1,
    countdown = new Countdown(),
    jsbridge = new Jsbridge(),
    lightConfirm = new LightConfirm(document.getElementById('light-confirm')),
    reminder = new Reminder(),
    audio = new Audio(document.getElementById('guest_audio'));
// video = new Video(document.getElementById('guest_video'));

lightConfirm.init();
reminder.init('');

$('#play-pause').on('tap', function () {
    // console.log(audio);
    if (!audio.canplay) return;
    if (audio.state === 'pause') {
        if (audio.audioElem.currentTime === audio.audioTotal) {
            $('.tape-runtime-text').text(0);
            $('.tape-runtime').width(0);
            audio.audioElem.currentTime = 0;
        }
        $('#play-audio').addClass('hide');
        $('#stop-audio').removeClass('hide');
        audio.play();
    } else {
        $('#stop-audio').addClass('hide');
        $('#play-audio').removeClass('hide');
        audio.pause();
    }
});

$('#previous-audio').on('tap', function () {
    // console.log(audio);
    $('.tape-runtime-text').text(0);
    $('.tape-runtime').width(0);
    audio.previous();
});

$('#next-audio').on('tap', function () {
    $('.tape-runtime-text').text(0);
    $('.tape-runtime').width(0);
    audio.next();
});

$('.next-guest-transition').on('transitionend', function () {
    // window.location.href = window.location.href;
    window.location.reload(true);
});

//获取用户的id和basic_auth
jsbridge.getOthers = function (userdata) {
    if (!userdata || !userdata.user_id || !userdata.access_token) {
        $('.next-guest-anim').addClass('hide');
        reminder.show('无法获取用户信息，请重试', 2000);
    } else if (!userdata.target_id) {
        if (parseInt(userdata.errorType) === 1) {
            (function () {
                var srcTime = new Date();
                var year = srcTime.getFullYear(),
                    monthNum = srcTime.getMonth(),
                    day = srcTime.getDate(),
                    hour = srcTime.getHours();
                var monthList = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
                if (hour >= 0 && hour < 5) {
                    countdown.init(monthList[monthNum] + ' ' + day + ',' + year + ' 5:00:00');
                    countdown.countdown();
                } else if (hour < 12 && hour >= 5) {
                    countdown.init(monthList[monthNum] + ' ' + day + ',' + year + ' 12:00:00');
                    countdown.countdown();
                } else if (hour >= 12 && hour < 19) {
                    countdown.init(monthList[monthNum] + ' ' + day + ',' + year + ' 19:00:00');
                    countdown.countdown();
                } else {
                    countdown.init(monthList[monthNum] + ' ' + (day + 1) + ',' + year + ' 5:00:00');
                    countdown.countdown();
                }
            })();
            // countdown.init('2016/4/28 19:53:20');
            // countdown.countdown();
            $('.next-guest-anim').addClass('hide');
            $('.index-miss-container').removeClass('hide');
        } else if (parseInt(userdata.errorType) === 2) {
            $('.next-guest-anim').addClass('hide');
            reminder.show('资料未完善，每天仅能查看三名嘉宾哦', 2000);
            setTimeout(function () {
                jsbridge.getData({
                    type: 'jump',
                    args: {
                        page: 'other_profile',
                        user_id: userdata.user_id
                    }
                }, null);
            }, 2100);
        }
    } else {
        user.user_id = userdata.user_id;
        user.access_token = userdata.access_token;
        user.target_id = userdata.target_id;
        $.when(getUserInfo(user), getUserAudio(user), getUserVideo(user, 'emotion_experience'), getUserVideo(user, 'value_concept')).done(function () {
            $('.next-guest-anim').addClass('hide');
            $('.content-area').removeClass('hide');
        }).fail(function () {
            // jsbridge.getData({
            //     type: 'log',
            //     args: {text: 'fail to load guest'}
            // }, null);
            console.log('fail to load guest information');
        });
    }
    // jsbridge.defer.resolve(1);
};

//更新每次用户的access_token
jsbridge.getAccessToken = function (accessData) {
    if (!accessData || !accessData.user_id || !accessData.access_token) {
        reminder.show('无法获取access_token，请重试', 2000);
        jsbridge.accessTokenDefer.reject();
    } else {
        user.user_id = accessData.user_id;
        user.access_token = accessData.access_token;
        jsbridge.accessTokenDefer.resolve(user);
    }
};

//获取目标用户信息
function getUserInfo(user) {
    var defer = $.Deferred();
    $.ajax({
        url: '/v1/account/get_user_info',
        type: 'POST',
        data: user
    }).done(function (data) {
        var result = data.data;
        var userShow = userInfo(result);
        $('.user-area').append(userShow);
        user.basic_info = result.basic_info_light_number;
        user.emotion_experience = result.emotion_experience_light_number;
        user.value_concept = result.value_concept_light_number;
        if (!user.basic_info) {
            $('.light-count').text('0');
        } else {
            $('.light-count').text(user.basic_info);
        }
        // $('.next-guest-anim').addClass('hide');
        // $('.content-area').removeClass('hide');
        defer.resolve();
    }).fail(function (xhr) {
        // console.log(user);
        // var userdata = userInfo(user_test);
        // $('.user-area').append(userdata);
        // $('.content-area').removeClass('hide');
        $('.next-guest-anim').addClass('hide');
        reminder.show('无法获取嘉宾信息，请重试', 2000);
        defer.reject();
    });
    return defer.promise();
}

//获取目标用户音频信息
function getUserAudio(user) {
    var defer = $.Deferred();
    $.ajax({
        url: '/v1/procedure/get_media',
        type: 'POST',
        data: {
            user_id: user.user_id,
            access_token: user.access_token,
            target_id: user.target_id,
            class: 'basic_info',
            file_type: 'audio'
        }
    }).done(function (data) {
        // for (var i = 0; i < data.length; i++) {
        //     if (data[i].question_order === 1) {
        //         document.getElementById('guest_audio').src = data[i].save_key;
        //     }
        // }
        var result = data.data;
        preloadAudio(defer, result.questions);
    }).fail(function (xhr) {
        if (xhr.status !== 403) {
            $('.next-guest-anim').addClass('hide');
            reminder.show('无法获取嘉宾音频资料，请重试', 2000);
        }
        defer.reject();
    });
    return defer.promise();
}

//获取用户视频信息
function getUserVideo(user, video_class) {
    var defer = $.Deferred();
    $.ajax({
        url: '/v1/procedure/get_media',
        type: 'POST',
        data: {
            user_id: user.user_id,
            access_token: user.access_token,
            target_id: user.target_id,
            class: video_class,
            file_type: 'video'
        }
    }).done(function (data) {
        var result = data.data;
        if (video_class === 'emotion_experience') {
            // document.getElementById('guest_video').src = data.save_key;
            preloadVideo(defer, [result], 'emotion_experience');
        } else {
            preloadVideo(defer, [result], 'value_concept');
        }
    }).fail(function (xhr) {
        if (xhr.status !== 403) {
            $('.next-guest-anim').addClass('hide');
            reminder.show('无法获取嘉宾视频资料，请重试', 2000);
        }
        defer.reject();
    });
    return defer.promise();
}

//预加载音频
function preloadAudio(defer, loadArr) {
    var count = loadArr.length,
        preloadArea = document.getElementById('preload-area');
    for (var i = 0, len = loadArr.length; i < len; i++) {
        var audioElem = document.createElement('audio');
        $(audioElem).on('canplaythrough', function () {
            count--;
            if (count === 0);
            audio.init(loadArr);
            return defer.resolve();
        });
        audioElem.setAttribute('src', loadArr[i].save_key);
        audioElem.load();
    }
}

//预加载视频
function preloadVideo(defer, loadArr, videoClass) {
    var count = loadArr.length,
        emotionVideo = document.getElementById('emotion_video'),
        valueVideo = document.getElementById('value_video'),
        preloadArea = document.getElementById('preload-area');
    // for (var i = 0, len = loadArr.length; i < len; i++) {
    //     var videoELem = document.createElement('video');
    //     $(videoELem).on('canplay', function () {
    //         count--;
    //         if (count === 0) {
    //             if (videoClass === 'emotion_experience') {
    //                 video.init(loadArr);
    //             } else {
    //                 video.append(loadArr);
    //             }
    //             return defer.resolve();
    //         }
    //     });
    //     videoELem.setAttribute('src', loadArr[i].save_key);
    //     videoELem.load();
    // }
    if (videoClass === 'emotion_experience') {
        emotionVideo.setAttribute('src', loadArr[0].save_key);
        emotionVideo.setAttribute('controls', 'controls');
        emotionVideo.load();
        return defer.resolve();
    } else if (videoClass === 'value_concept') {
        valueVideo.setAttribute('src', loadArr[0].save_key);
        valueVideo.setAttribute('controls', 'controls');
        valueVideo.load();
        return defer.resolve();
    }
}

//亮灯进入下一个阶段
$('#light-up').on('tap', function (e) {
    if (!jsbridge.accessStatus) {
        return;
    }
    if (stage === 5 || stage > 5) {
        reminder.show('所有灯已经点亮完毕，请点击下一位，观看下一位嘉宾', 2000);
        return;
    } else if (stage === 1) {
        var guestAudio = document.getElementById('guest_audio');
        audio.state = 'pause';
        guestAudio.pause();
        $('#stop-audio').addClass('hide');
        $('#play-audio').removeClass('hide');
    } else if (stage === 2) {
        var emotionVideo = document.getElementById('emotion_video');
        emotionVideo.pause();
    } else if (stage === 3) {
        var valueVideo = document.getElementById('value_video');
        valueVideo.pause();
    }
    $.when(jsbridge.getData({
        type: 'getAccessToken',
        args: {}
    }, jsbridge.getAccessToken, 'access_token')).done(function (user) {
        var data = {};
        data.user_id = user.user_id;
        data.access_token = user.access_token;
        data.target_id = user.target_id;
        data.order = stage;
        data.light_status = 1;
        stage += 1;
        if (stage === 4) {
            $('.light-reminder').removeClass('hide');
            $.when(lightConfirm.show()).done(function () {
                $('.light-reminder').addClass('hide');
                $('.next-guest-anim').removeClass('hide');
                $.ajax({
                    url: '/v1/procedure/light_up',
                    type: 'POST',
                    data: data
                }).done(function () {
                    $.ajax({
                        url: '/v1/procedure/log_have_seen',
                        type: 'POST',
                        data: {
                            user_id: data.user_id,
                            access_token: data.access_token,
                            target_id: data.target_id
                        }
                    }).done(function (data) {
                        jsbridge.accessStatus = true;
                        stage += 1;
                        $('.next-guest-anim').addClass('hide');
                        $('.next-guest-transition').addClass('change-next-guest');
                    }).fail(function () {
                        stage = data.order;
                        jsbridge.accessStatus = true;
                        $('.next-guest-anim').addClass('hide');
                        reminder.show('亮灯失败，请重试', 2000);
                    });
                    // window.location.reload();
                }).fail(function (xhr) {
                    if (xhr.status === 403) {
                        stage = data.order;
                        $('.next-guest-anim').addClass('hide');
                        reminder.show('资料未完善，每天仅有两次亮灯机会哦', 2000);
                        setTimeout(function () {
                            jsbridge.getData({
                                type: 'jump',
                                args: {
                                    page: 'other_profile',
                                    user_id: data.user_id
                                }
                            }, null);
                        }, 2100);
                    } else {
                        stage = data.order;
                        jsbridge.accessStatus = true;
                        // console.log(stage);
                        $('.next-guest-anim').addClass('hide');
                        reminder.show('亮灯失败，请重试', 2000);
                    }
                });
            }).fail(function () {
                $('.light-reminder').addClass('hide');
                stage = data.order;
                jsbridge.accessStatus = true;
                // console.log(stage);
            });
        } else {
            $('.next-guest-anim').removeClass('hide');
            $.ajax({
                url: '/v1/procedure/light_up',
                type: 'POST',
                data: data
            }).done(function () {
                jsbridge.accessStatus = true;
                $('.next-guest-anim').addClass('hide');
                $('body').on('transitionend', function (e) {
                    var $this = $(e.currentTarget);
                    $this.off('transitionend');
                    if ($this.hasClass('fade')) {
                        if (stage === 2) {
                            $('.audio-container').addClass('hide');
                            $('.video-container').removeClass('hide');
                            $('.video-name').text('TA的情感经历');
                            if (!user.emotion_experience) {
                                $('.light-count').text('0');
                            } else {
                                $('.light-count').text(user.emotion_experience);
                            }
                        } else if (stage === 3) {
                            // video.next();
                            $('#emotion_video').addClass('hide');
                            $('#value_video').removeClass('hide');
                            $('.video-name').text('TA的价值观');
                            if (!user.value_concept) {
                                $('.light-count').text('0');
                            } else {
                                $('.light-count').text(user.value_concept);
                            }
                        }
                        setTimeout(function () {
                            $this.removeClass('fade');
                        }, 550);
                    }
                });
                $('body').addClass('fade');
            }).fail(function (xhr) {
                if (xhr.status === 403) {
                    stage = data.order;
                    $('.next-guest-anim').addClass('hide');
                    reminder.show('资料未完善，每天仅有两次亮灯机会哦', 2000);
                    setTimeout(function () {
                        jsbridge.getData({
                            type: 'jump',
                            args: {
                                page: 'other_profile',
                                user_id: data.user_id
                            }
                        }, null);
                    }, 2100);
                } else {
                    jsbridge.accessStatus = true;
                    stage = data.order;
                    // console.log(stage);
                    $('.next-guest-anim').addClass('hide');
                    reminder.show('亮灯失败，请重试', 2000);
                }
            });
        }
    }).fail(function () {
        jsbridge.accessStatus = true;
    });
});

//点击下一位按钮切换下一位嘉宾
$('#next-guest').on('tap', function (e) {
	if (stage === 1) {
	    var guestAudio = document.getElementById('guest_audio');
	    audio.state = 'pause';
	    guestAudio.pause();
	    $('#stop-audio').addClass('hide');
	    $('#play-audio').removeClass('hide');
	} else if (stage === 2) {
	    var emotionVideo = document.getElementById('emotion_video');
	    emotionVideo.pause();
	} else if (stage === 3) {
	    var valueVideo = document.getElementById('value_video');
	    valueVideo.pause();
	}
    $('.next-guest-transition').addClass('change-next-guest');
});

// countdown.init('2016/05/12 22:35:00');
// countdown.countdown();
// $('.next-guest-anim').addClass('hide');
// $('.index-miss-container').removeClass('hide');

jsbridge.getData({
    type: 'getOthers',
    args: {}
}, jsbridge.getOthers);
