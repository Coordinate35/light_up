/******/ (function(modules) { // webpackBootstrap
/******/ 	// The module cache
/******/ 	var installedModules = {};

/******/ 	// The require function
/******/ 	function __webpack_require__(moduleId) {

/******/ 		// Check if module is in cache
/******/ 		if(installedModules[moduleId])
/******/ 			return installedModules[moduleId].exports;

/******/ 		// Create a new module (and put it into the cache)
/******/ 		var module = installedModules[moduleId] = {
/******/ 			exports: {},
/******/ 			id: moduleId,
/******/ 			loaded: false
/******/ 		};

/******/ 		// Execute the module function
/******/ 		modules[moduleId].call(module.exports, module, module.exports, __webpack_require__);

/******/ 		// Flag the module as loaded
/******/ 		module.loaded = true;

/******/ 		// Return the exports of the module
/******/ 		return module.exports;
/******/ 	}


/******/ 	// expose the modules object (__webpack_modules__)
/******/ 	__webpack_require__.m = modules;

/******/ 	// expose the module cache
/******/ 	__webpack_require__.c = installedModules;

/******/ 	// __webpack_public_path__
/******/ 	__webpack_require__.p = "";

/******/ 	// Load entry module and return exports
/******/ 	return __webpack_require__(0);
/******/ })
/************************************************************************/
/******/ ([
/* 0 */
/***/ function(module, exports, __webpack_require__) {

	var Jsbridge = __webpack_require__(1);
	var LightConfirm = __webpack_require__(10);
	var Reminder = __webpack_require__(2);
	var Audio = __webpack_require__(14);
	var Video = __webpack_require__(15);
	var Countdown = __webpack_require__(16);

	var userInfo = __webpack_require__(17);

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


/***/ },
/* 1 */
/***/ function(module, exports) {

	window.Hybrid = window.Hybrid || {};

	function Jsbridge() {
	    this.accessTokenDefer = null;
	    this.accessStatus = true;
	}

	Jsbridge.prototype.getData = function (opts, callback, deferType) {
	    var url = 'lightupjs://';
	    var tt = (new Date().getTime());
	    var t = 'hybrid_' + tt;
	    if (!!callback) {
	        window.Hybrid[t] = function (data) {
	            callback(data);
	            delete window.Hybrid[t];
	        };
	        opts.call = "Hybrid['" + t + "']";
	    }
	    // console.log(opts);
	    url += JSON.stringify(opts);
	    var iframe = document.createElement('iframe');
	    iframe.style.width = '1px';
	    iframe.style.height = '1px';
	    iframe.style.display = 'none';
	    iframe.src = url;
	    // iframe.onload = function () {
	    //     iframe.remove();
	    // };
	    setTimeout(function () {
	        iframe.remove();
	    }, 1000);
	    document.body.appendChild(iframe);
	    if (deferType === 'access_token') {
	        this.accessStatus = false;
	        this.accessTokenDefer = $.Deferred();
	        return this.accessTokenDefer.promise();
	    }
	};

	module.exports = Jsbridge;


/***/ },
/* 2 */
/***/ function(module, exports, __webpack_require__) {

	__webpack_require__(3);
	var reminder = __webpack_require__(7);

	function Reminder() {
	    this.timeId = null;
	    this.status = 'hide';
	}

	Reminder.prototype.show = function (content, timeout) {
	    var self = this;
	    if (self.status === 'show') {
	        return;
	    }
	    $('.reminder-content').text(content);
	    $('.reminder-modal').removeClass('reminder-hide');
	    self.status = 'show';
	    // console.log(self);
	    this.timeId = setTimeout(function () {
	        self.status = 'hide';
	        // console.log(self);
	        $('.reminder-modal').addClass('reminder-hide');
	    }, timeout);
	};

	Reminder.prototype.init = function (content) {
	    var self = this;
	    content = content || '';
	    $('body').append(reminder({content: content}));
	    $('.reminder-modal').on('tap', function (e) {
	        // if (($(e.target).attr('id') === 'light-up') || ($(e.target).parent().attr('id') === 'light-up')) {
	        //     return;
	        // }
	        if (self.status === 'show') {
	            self.status = 'hide';
	            // console.log(self);
	            clearTimeout(self.timeId);
	            $('.reminder-modal').addClass('reminder-hide');
	        }
	    });
	};

	module.exports = Reminder;

/***/ },
/* 3 */
/***/ function(module, exports, __webpack_require__) {

	// style-loader: Adds some css to the DOM by adding a <style> tag

	// load the styles
	var content = __webpack_require__(4);
	if(typeof content === 'string') content = [[module.id, content, '']];
	// add the styles to the DOM
	var update = __webpack_require__(6)(content, {});
	if(content.locals) module.exports = content.locals;
	// Hot Module Replacement
	if(false) {
		// When the styles change, update the <style> tags
		if(!content.locals) {
			module.hot.accept("!!./../../../node_modules/css-loader/index.js?minimize&-autoprefixer!./reminder_modal.css", function() {
				var newContent = require("!!./../../../node_modules/css-loader/index.js?minimize&-autoprefixer!./reminder_modal.css");
				if(typeof newContent === 'string') newContent = [[module.id, newContent, '']];
				update(newContent);
			});
		}
		// When the module is disposed, remove the <style> tags
		module.hot.dispose(function() { update(); });
	}

/***/ },
/* 4 */
/***/ function(module, exports, __webpack_require__) {

	exports = module.exports = __webpack_require__(5)();
	// imports


	// module
	exports.push([module.id, ".reminder-modal{position:absolute;top:45%;left:50%;-moz-transform:translate(-50%,-50%);-ms-transform:translate(-50%,-50%);-webkit-transform:translate(-50%,-50%);transform:translate(-50%,-50%);width:80%;padding:8% 5%;background-color:#999;color:#fff;border-radius:5px;z-index:4}.reminder-content{font-size:1rem;line-height:1.5;text-align:center}.reminder-hide{display:none}", ""]);

	// exports


/***/ },
/* 5 */
/***/ function(module, exports) {

	/*
		MIT License http://www.opensource.org/licenses/mit-license.php
		Author Tobias Koppers @sokra
	*/
	// css base code, injected by the css-loader
	module.exports = function() {
		var list = [];

		// return the list of modules as css string
		list.toString = function toString() {
			var result = [];
			for(var i = 0; i < this.length; i++) {
				var item = this[i];
				if(item[2]) {
					result.push("@media " + item[2] + "{" + item[1] + "}");
				} else {
					result.push(item[1]);
				}
			}
			return result.join("");
		};

		// import a list of modules into the list
		list.i = function(modules, mediaQuery) {
			if(typeof modules === "string")
				modules = [[null, modules, ""]];
			var alreadyImportedModules = {};
			for(var i = 0; i < this.length; i++) {
				var id = this[i][0];
				if(typeof id === "number")
					alreadyImportedModules[id] = true;
			}
			for(i = 0; i < modules.length; i++) {
				var item = modules[i];
				// skip already imported module
				// this implementation is not 100% perfect for weird media query combinations
				//  when a module is imported multiple times with different media queries.
				//  I hope this will never occur (Hey this way we have smaller bundles)
				if(typeof item[0] !== "number" || !alreadyImportedModules[item[0]]) {
					if(mediaQuery && !item[2]) {
						item[2] = mediaQuery;
					} else if(mediaQuery) {
						item[2] = "(" + item[2] + ") and (" + mediaQuery + ")";
					}
					list.push(item);
				}
			}
		};
		return list;
	};


/***/ },
/* 6 */
/***/ function(module, exports, __webpack_require__) {

	/*
		MIT License http://www.opensource.org/licenses/mit-license.php
		Author Tobias Koppers @sokra
	*/
	var stylesInDom = {},
		memoize = function(fn) {
			var memo;
			return function () {
				if (typeof memo === "undefined") memo = fn.apply(this, arguments);
				return memo;
			};
		},
		isOldIE = memoize(function() {
			return /msie [6-9]\b/.test(window.navigator.userAgent.toLowerCase());
		}),
		getHeadElement = memoize(function () {
			return document.head || document.getElementsByTagName("head")[0];
		}),
		singletonElement = null,
		singletonCounter = 0,
		styleElementsInsertedAtTop = [];

	module.exports = function(list, options) {
		if(false) {
			if(typeof document !== "object") throw new Error("The style-loader cannot be used in a non-browser environment");
		}

		options = options || {};
		// Force single-tag solution on IE6-9, which has a hard limit on the # of <style>
		// tags it will allow on a page
		if (typeof options.singleton === "undefined") options.singleton = isOldIE();

		// By default, add <style> tags to the bottom of <head>.
		if (typeof options.insertAt === "undefined") options.insertAt = "bottom";

		var styles = listToStyles(list);
		addStylesToDom(styles, options);

		return function update(newList) {
			var mayRemove = [];
			for(var i = 0; i < styles.length; i++) {
				var item = styles[i];
				var domStyle = stylesInDom[item.id];
				domStyle.refs--;
				mayRemove.push(domStyle);
			}
			if(newList) {
				var newStyles = listToStyles(newList);
				addStylesToDom(newStyles, options);
			}
			for(var i = 0; i < mayRemove.length; i++) {
				var domStyle = mayRemove[i];
				if(domStyle.refs === 0) {
					for(var j = 0; j < domStyle.parts.length; j++)
						domStyle.parts[j]();
					delete stylesInDom[domStyle.id];
				}
			}
		};
	}

	function addStylesToDom(styles, options) {
		for(var i = 0; i < styles.length; i++) {
			var item = styles[i];
			var domStyle = stylesInDom[item.id];
			if(domStyle) {
				domStyle.refs++;
				for(var j = 0; j < domStyle.parts.length; j++) {
					domStyle.parts[j](item.parts[j]);
				}
				for(; j < item.parts.length; j++) {
					domStyle.parts.push(addStyle(item.parts[j], options));
				}
			} else {
				var parts = [];
				for(var j = 0; j < item.parts.length; j++) {
					parts.push(addStyle(item.parts[j], options));
				}
				stylesInDom[item.id] = {id: item.id, refs: 1, parts: parts};
			}
		}
	}

	function listToStyles(list) {
		var styles = [];
		var newStyles = {};
		for(var i = 0; i < list.length; i++) {
			var item = list[i];
			var id = item[0];
			var css = item[1];
			var media = item[2];
			var sourceMap = item[3];
			var part = {css: css, media: media, sourceMap: sourceMap};
			if(!newStyles[id])
				styles.push(newStyles[id] = {id: id, parts: [part]});
			else
				newStyles[id].parts.push(part);
		}
		return styles;
	}

	function insertStyleElement(options, styleElement) {
		var head = getHeadElement();
		var lastStyleElementInsertedAtTop = styleElementsInsertedAtTop[styleElementsInsertedAtTop.length - 1];
		if (options.insertAt === "top") {
			if(!lastStyleElementInsertedAtTop) {
				head.insertBefore(styleElement, head.firstChild);
			} else if(lastStyleElementInsertedAtTop.nextSibling) {
				head.insertBefore(styleElement, lastStyleElementInsertedAtTop.nextSibling);
			} else {
				head.appendChild(styleElement);
			}
			styleElementsInsertedAtTop.push(styleElement);
		} else if (options.insertAt === "bottom") {
			head.appendChild(styleElement);
		} else {
			throw new Error("Invalid value for parameter 'insertAt'. Must be 'top' or 'bottom'.");
		}
	}

	function removeStyleElement(styleElement) {
		styleElement.parentNode.removeChild(styleElement);
		var idx = styleElementsInsertedAtTop.indexOf(styleElement);
		if(idx >= 0) {
			styleElementsInsertedAtTop.splice(idx, 1);
		}
	}

	function createStyleElement(options) {
		var styleElement = document.createElement("style");
		styleElement.type = "text/css";
		insertStyleElement(options, styleElement);
		return styleElement;
	}

	function createLinkElement(options) {
		var linkElement = document.createElement("link");
		linkElement.rel = "stylesheet";
		insertStyleElement(options, linkElement);
		return linkElement;
	}

	function addStyle(obj, options) {
		var styleElement, update, remove;

		if (options.singleton) {
			var styleIndex = singletonCounter++;
			styleElement = singletonElement || (singletonElement = createStyleElement(options));
			update = applyToSingletonTag.bind(null, styleElement, styleIndex, false);
			remove = applyToSingletonTag.bind(null, styleElement, styleIndex, true);
		} else if(obj.sourceMap &&
			typeof URL === "function" &&
			typeof URL.createObjectURL === "function" &&
			typeof URL.revokeObjectURL === "function" &&
			typeof Blob === "function" &&
			typeof btoa === "function") {
			styleElement = createLinkElement(options);
			update = updateLink.bind(null, styleElement);
			remove = function() {
				removeStyleElement(styleElement);
				if(styleElement.href)
					URL.revokeObjectURL(styleElement.href);
			};
		} else {
			styleElement = createStyleElement(options);
			update = applyToTag.bind(null, styleElement);
			remove = function() {
				removeStyleElement(styleElement);
			};
		}

		update(obj);

		return function updateStyle(newObj) {
			if(newObj) {
				if(newObj.css === obj.css && newObj.media === obj.media && newObj.sourceMap === obj.sourceMap)
					return;
				update(obj = newObj);
			} else {
				remove();
			}
		};
	}

	var replaceText = (function () {
		var textStore = [];

		return function (index, replacement) {
			textStore[index] = replacement;
			return textStore.filter(Boolean).join('\n');
		};
	})();

	function applyToSingletonTag(styleElement, index, remove, obj) {
		var css = remove ? "" : obj.css;

		if (styleElement.styleSheet) {
			styleElement.styleSheet.cssText = replaceText(index, css);
		} else {
			var cssNode = document.createTextNode(css);
			var childNodes = styleElement.childNodes;
			if (childNodes[index]) styleElement.removeChild(childNodes[index]);
			if (childNodes.length) {
				styleElement.insertBefore(cssNode, childNodes[index]);
			} else {
				styleElement.appendChild(cssNode);
			}
		}
	}

	function applyToTag(styleElement, obj) {
		var css = obj.css;
		var media = obj.media;

		if(media) {
			styleElement.setAttribute("media", media)
		}

		if(styleElement.styleSheet) {
			styleElement.styleSheet.cssText = css;
		} else {
			while(styleElement.firstChild) {
				styleElement.removeChild(styleElement.firstChild);
			}
			styleElement.appendChild(document.createTextNode(css));
		}
	}

	function updateLink(linkElement, obj) {
		var css = obj.css;
		var sourceMap = obj.sourceMap;

		if(sourceMap) {
			// http://stackoverflow.com/a/26603875
			css += "\n/*# sourceMappingURL=data:application/json;base64," + btoa(unescape(encodeURIComponent(JSON.stringify(sourceMap)))) + " */";
		}

		var blob = new Blob([css], { type: "text/css" });

		var oldSrc = linkElement.href;

		linkElement.href = URL.createObjectURL(blob);

		if(oldSrc)
			URL.revokeObjectURL(oldSrc);
	}


/***/ },
/* 7 */
/***/ function(module, exports, __webpack_require__) {

	var template=__webpack_require__(8);
	module.exports=template('tpl/modules/reminder/reminder',function($data,$filename
	/**/) {
	'use strict';var $utils=this,$helpers=$utils.$helpers,$escape=$utils.$escape,content=$data.content,$out='';$out+='<section class="reminder-modal reminder-hide"> <p class="reminder-content">';
	$out+=$escape(content);
	$out+='</p> </section>';
	return new String($out);
	});

/***/ },
/* 8 */
/***/ function(module, exports) {

	/*TMODJS:{}*/
	!function () {
		function a(a, b) {
			return (/string|function/.test(typeof b) ? h : g)(a, b)
		}

		function b(a, c) {
			return "string" != typeof a && (c = typeof a, "number" === c ? a += "" : a = "function" === c ? b(a.call(a)) : ""), a
		}

		function c(a) {
			return l[a]
		}

		function d(a) {
			return b(a).replace(/&(?![\w#]+;)|[<>"']/g, c)
		}

		function e(a, b) {
			if (m(a))for (var c = 0, d = a.length; d > c; c++)b.call(a, a[c], c, a); else for (c in a)b.call(a, a[c], c)
		}

		function f(a, b) {
			var c = /(\/)[^\/]+\1\.\.\1/, d = ("./" + a).replace(/[^\/]+$/, ""), e = d + b;
			for (e = e.replace(/\/\.\//g, "/"); e.match(c);)e = e.replace(c, "/");
			return e
		}

		function g(b, c) {
			var d = a.get(b) || i({filename: b, name: "Render Error", message: "Template not found"});
			return c ? d(c) : d
		}

		function h(a, b) {
			if ("string" == typeof b) {
				var c = b;
				b = function () {
					return new k(c)
				}
			}
			var d = j[a] = function (c) {
				try {
					return new b(c, a) + ""
				} catch (d) {
					return i(d)()
				}
			};
			return d.prototype = b.prototype = n, d.toString = function () {
				return b + ""
			}, d
		}

		function i(a) {
			var b = "{Template Error}", c = a.stack || "";
			if (c)c = c.split("\n").slice(0, 2).join("\n"); else for (var d in a)c += "<" + d + ">\n" + a[d] + "\n\n";
			return function () {
				return "object" == typeof console && console.error(b + "\n\n" + c), b
			}
		}

		var j = a.cache = {}, k = this.String, l = {
			"<": "&#60;",
			">": "&#62;",
			'"': "&#34;",
			"'": "&#39;",
			"&": "&#38;"
		}, m = Array.isArray || function (a) {
				return "[object Array]" === {}.toString.call(a)
			}, n = a.utils = {
			$helpers: {}, $include: function (a, b, c) {
				return a = f(c, a), g(a, b)
			}, $string: b, $escape: d, $each: e
		}, o = a.helpers = n.$helpers;
		a.get = function (a) {
			return j[a.replace(/^\.\//, "")]
		}, a.helper = function (a, b) {
			o[a] = b
		}, module.exports = a
	}();

/***/ },
/* 9 */,
/* 10 */
/***/ function(module, exports, __webpack_require__) {

	__webpack_require__(11);
	var light_confirm = __webpack_require__(13);

	function LightConfirm(lightConfirmElem) {
	    this.defer = null;
	    this.lightConfirmElem = lightConfirmElem;
	    this.$lightConfirmElem = $(lightConfirmElem);
	}

	LightConfirm.prototype.show = function () {
	    this.defer = $.Deferred();
	    this.$lightConfirmElem.removeClass('hide');
	    return this.defer.promise();
	};

	LightConfirm.prototype.hide = function () {
	    this.$lightConfirmElem.addClass('hide');
	};

	LightConfirm.prototype.init = function () {
	    var self = this;
	    $('body').append(light_confirm());
	    $('#cancel-light').on('tap', function (e) {
	        self.defer.reject();
	    });
	    $('#confirm-light').on('tap', function (e) {
	        self.defer.resolve();
	    });
	};

	module.exports = LightConfirm;


/***/ },
/* 11 */
/***/ function(module, exports, __webpack_require__) {

	// style-loader: Adds some css to the DOM by adding a <style> tag

	// load the styles
	var content = __webpack_require__(12);
	if(typeof content === 'string') content = [[module.id, content, '']];
	// add the styles to the DOM
	var update = __webpack_require__(6)(content, {});
	if(content.locals) module.exports = content.locals;
	// Hot Module Replacement
	if(false) {
		// When the styles change, update the <style> tags
		if(!content.locals) {
			module.hot.accept("!!./../../../node_modules/css-loader/index.js?minimize&-autoprefixer!./light_confirm.css", function() {
				var newContent = require("!!./../../../node_modules/css-loader/index.js?minimize&-autoprefixer!./light_confirm.css");
				if(typeof newContent === 'string') newContent = [[module.id, newContent, '']];
				update(newContent);
			});
		}
		// When the module is disposed, remove the <style> tags
		module.hot.dispose(function() { update(); });
	}

/***/ },
/* 12 */
/***/ function(module, exports, __webpack_require__) {

	exports = module.exports = __webpack_require__(5)();
	// imports


	// module
	exports.push([module.id, ".light-reminder{position:absolute;width:90%;top:45%;left:50%;-moz-transform:translate(-50%,-50%);-ms-transform:translate(-50%,-50%);-webkit-transform:translate(-50%,-50%);transform:translate(-50%,-50%);z-index:3;border-radius:5px;background-color:#333;font-size:1rem;color:#fff;text-align:center;padding-top:10px}.light-reminder p{line-height:1.2;padding:0 20px}.light-reminder .light-reminder-title{font-size:1.125rem;font-weight:700;margin-bottom:12px}.light-reminder .light-reminder-control{margin-top:25px;border-top:2px solid #f5407e;font-size:0}.light-reminder .light-reminder-control a{display:inline-block;width:50%;padding:15px 10px;font-size:1.125rem;text-align:center;color:#fff;box-sizing:border-box}.light-reminder .light-reminder-control #cancel-light{border-right:1px solid #f5407e}.light-reminder .light-reminder-control #confirm-light{border-left:1px solid #f5407e;color:#f5407e}", ""]);

	// exports


/***/ },
/* 13 */
/***/ function(module, exports, __webpack_require__) {

	var template=__webpack_require__(8);
	module.exports=template('tpl/modules/light_confirm/light_confirm','<section id="light-confirm" class="light-reminder hide"> <p class="light-reminder-title">噔噔</p> <p>如果点亮第三盏灯，你的个人页面和联系方式会发送给对方，然后就默默等待对方翻牌子吧</p> <div class="light-reminder-control"> <a href="javascript:;" id="cancel-light">不要了</a> <a href="javascript:;" id="confirm-light">好啊</a> </div> </section>');

/***/ },
/* 14 */
/***/ function(module, exports) {

	function Audio(audioElem) {
	    this.curAudio = 0;
	    this.audios = [];
	    this.audioElem = audioElem;
	    this.audioTotal = 0;
	    this.state = 'pause';
	    this.canplay = false;
	}

	Audio.prototype.init = function (audioArr) {
	    var self = this;
	    this.audioElem.addEventListener('canplay', function (e) {
	        self.audioTotal = parseInt(e.target.duration);
	        self.canplay = true;
	        // console.log(self);
	    }, false);
	    for (var i = 0; i < audioArr.length; i++) {
	        var start = audioArr[i].question_order - 1;
	        if (start === 0) {
	            $('.tape-question-content').text(audioArr[i].question_content);
	            this.audioElem.src = audioArr[i].save_key;
	            this.audioElem.load();
	        }
	        this.audios.splice(start, 0, audioArr[i]);
	    }
	    // console.log(this.audios);
	    this.audioElem.addEventListener('timeupdate', function (e) {
	        var curTime = parseInt(e.target.currentTime);
	        var playpercent = parseInt(curTime / self.audioTotal * 100) + '%';
	        if (curTime === self.audioTotal) {
	            self.state = 'pause';
	            $('#stop-audio').addClass('hide');
	            $('#play-audio').removeClass('hide');
	        }
	        $('.tape-runtime-text').text(curTime);
	        $('.tape-runtime').width(playpercent);
	    }, false);
	};

	Audio.prototype.play = function () {
	    this.state = 'play';
	    this.audioElem.play();
	};

	Audio.prototype.pause = function () {
	    this.state = 'pause';
	    this.audioElem.pause();
	};

	Audio.prototype.next = function () {
	    $('#stop-audio').addClass('hide');
	    $('#play-audio').removeClass('hide');
	    this.state = 'pause';
	    this.canplay = false;
	    // console.log(this);
	    if (this.curAudio === this.audios.length - 1) {
	        this.curAudio = 0;
	    } else {
	        this.curAudio += 1;
	    }
	    var curAudio = this.audios[this.curAudio];
	    $('.tape-question-content').text(curAudio.question_content);
	    this.audioElem.src = curAudio.save_key;
	    this.audioElem.load();
	};

	Audio.prototype.previous = function () {
	    $('#stop-audio').addClass('hide');
	    $('#play-audio').removeClass('hide');
	    this.state = 'pause';
	    this.canplay = false;
	    // console.log(this);
	    if (this.curAudio === 0) {
	        this.curAudio = this.audios.length - 1;
	    } else {
	        this.curAudio -= 1;
	    }
	    var curAudio = this.audios[this.curAudio];
	    $('.tape-question-content').text(curAudio.question_content);
	    this.audioElem.src = curAudio.save_key;
	    this.audioElem.load();
	};

	module.exports = Audio;


/***/ },
/* 15 */
/***/ function(module, exports) {

	function Video(videoElem) {
	    this.videoElem = videoElem;
	    this.videos = [];
	    this.curVideo = 0;
	}

	Video.prototype.init = function (videoData) {
	    var videoElem = this.videoElem,
	        self = this;
	    this.videos.push(videoData[0]);
	    videoElem.addEventListener('canplaythrough', function (e) {
	        if (self.curVideo === 1) {
	            $('.loading-container').addClass('hide');
	        }
	    }, false);
	    videoElem.src = videoData[0].save_key;
	    videoElem.load();
	};

	Video.prototype.append = function (videoData) {
	    this.videos.push(videoData[0]);
	};

	Video.prototype.next = function () {
	    var videoElem = this.videoElem;
	    this.curVideo += 1;
	    videoElem.src = this.videos[this.curVideo].save_key;
	    videoElem.load();
	};

	module.exports = Video;


/***/ },
/* 16 */
/***/ function(module, exports) {

	function Countdown() {

	}

	function countdown(destTime) {
	    var srcTime = (new Date()).getTime();
	    var diffTime = Math.floor((destTime - srcTime) / 1000);
	    var hours = Math.floor(diffTime / 3600);
	    hours = (hours < 10) ? '0' + hours : hours;
	    var minutes = Math.floor((diffTime - hours * 3600) / 60);
	    minutes = (minutes < 10) ? '0' + minutes : minutes;
	    var seconds = diffTime - hours * 3600 - minutes * 60;
	    seconds = (seconds < 10) ? '0' + seconds : seconds;
	    var time = hours + ':' + minutes + ':' + seconds;
	    // console.log(destTime, hours, minutes, seconds);
	    $('.countdown').text(time);
	    if (hours === 0 && minutes === 0 && seconds === 0) {
	        window.location.href = window.location.reload(true);
	        return;
	    }
	    // console.log(diffTime, hours, minutes, seconds);
	    setTimeout(function () {
	        countdown(destTime);
	    }, 1000);
	}

	Countdown.prototype.init = function (time) {
	    this.destTime = (new Date(time)).getTime();
	    // console.log(time, typeof time, this.destTime);
	};

	Countdown.prototype.countdown = function () {
	    countdown(this.destTime);
	};

	module.exports = Countdown;


/***/ },
/* 17 */
/***/ function(module, exports, __webpack_require__) {

	var template=__webpack_require__(8);
	module.exports=template('tpl/index_user',function($data,$filename
	/**/) {
	'use strict';var $utils=this,$helpers=$utils.$helpers,$escape=$utils.$escape,portrait=$data.portrait,nickname=$data.nickname,sex=$data.sex,age=$data.age,location=$data.location,$out='';$out+='<img class="user-potrait" src="';
	$out+=$escape(portrait);
	$out+='"></img> <div class="user-info"> <p> <span class="username">';
	$out+=$escape(nickname);
	$out+='</span> ';
	if(sex === 'male'){
	$out+=' <img src="images/video_index/ic_me_male@2x.png" class="sex"> ';
	}else{
	$out+=' <img src="images/video_index/ic_me_female@2x.png" class="sex"> ';
	}
	$out+=' </p> <p> <span class="age">';
	$out+=$escape(age);
	$out+='</span> ';
	if(sex === 'male'){
	$out+=' <span class="sex-orientation">男性</span> ';
	}else{
	$out+=' <span class="sex-orientation">女性</span> ';
	}
	$out+=' <span class="location">';
	$out+=$escape(location);
	$out+='</span> </p> </div>';
	return new String($out);
	});

/***/ }
/******/ ]);