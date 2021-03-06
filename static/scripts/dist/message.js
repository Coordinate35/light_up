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
	var Reminder = __webpack_require__(2);

	var messgeResults = __webpack_require__(9);

	var user = {},
	    jsbridge = new Jsbridge(),
	    reminder = new Reminder();

	// var test_data = {
	//     logs: [{
	//         content: '我为你点亮了三盏灯，快来联系我吧！',
	//         lighter: {
	//             portrait: '',
	//             nickname: 'jason'
	//         },
	//         time: 1460900510
	//     },{
	//         content: '我为你点亮了三盏灯，快来联系我吧！',
	//         lighter: {
	//             portrait: '',
	//             nickname: 'jason'
	//         },
	//         time: 1460900510
	//     },{
	//         content: '我为你点亮了三盏灯，快来联系我吧！',
	//         lighter: {
	//             portrait: '',
	//             nickname: 'jason'
	//         },
	//         time: 1460900510
	//     }]
	// };

	// var test_data = {
	//     logs: []
	// };

	reminder.init();

	//获取用户的id和basic_auth
	jsbridge.getOthers = function(userdata) {
	    // console.log(userdata);
	    // jsbridge.getData({
	    //     'type': 'log',
	    //     args: {text: JSON.stringify(userdata)}
	    // }, null);
	    // alert('userdata: ' + userdata);
	    // alert('userdata.user_id: ' + userdata.user_id);
	    // alert('userdata.access_token: ' + userdata.access_token);
	    if (!userdata || !userdata.user_id || !userdata.access_token) {
	        $('.loading-container').addClass('hide');
	        reminder.show('无法获取用户信息，请重试', 2000);
	    } else {
	        user.user_id = userdata.user_id;
	        user.access_token = userdata.access_token;
	        // user.target_id = userdata.target_id;
	        $.when(getUserMes(user)).done(function() {

	        }).fail(function() {
	            // jsbridge.getData({
	            //     type: 'log',
	            //     args: {text: 'fail to load guest'}
	            // }, null);
	            console.log('fail to load user information');
	        });
	    }
	    // jsbridge.defer.resolve(1);
	};

	function getUserMes(user) {
	    var defer = $.Deferred();
	    $.ajax({
	        url: '/v1/procedure/get_message',
	        type: 'POST',
	        data: {
	            user_id: user.user_id,
	            access_token: user.access_token
	        }
	    }).done(function(result) {
	        // console.log(result);
	        if (result.data.logs.length === 0) {
	            $('.loading-container').addClass('hide');
	            $('.message-miss').removeClass('hide');
	        } else {
	            $('.message-area').append(messgeResults(result.data));
	            $('.loading-container').addClass('hide');
	            $('.message-area').removeClass('hide');
	            $('.message-item').on('tap', function(e) {
	                var userInput = $(e.currentTarget).children('input')[0],
	                    user_id = $(userInput).val();
	                jsbridge.getData({
	                    type: 'jump',
	                    args: {
	                        page: 'other_profile',
	                        user_id: user_id
	                    }
	                }, null);
	            });
	        }
	        defer.resolve();
	    }).fail(function() {
	        $('.loading-container').addClass('hide');
	        reminder.show('无法获取用户消息，请重试', 2000);
	    });
	    return defer.promise();
	}

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
/* 9 */
/***/ function(module, exports, __webpack_require__) {

	var template=__webpack_require__(8);
	module.exports=template('tpl/message',function($data,$filename
	/**/) {
	'use strict';var $utils=this,$helpers=$utils.$helpers,$each=$utils.$each,logs=$data.logs,$value=$data.$value,$index=$data.$index,$escape=$utils.$escape,$out='';$each(logs,function($value,$index){
	$out+=' <div class="message-item">  <input type="hidden" value="';
	$out+=$escape($value.lighter.user_id);
	$out+='"> <img class="user-potrait" src="';
	$out+=$escape($value.lighter.portrait);
	$out+='"> <div class="mes-box"> <div class="mes-container"> <p class="username">';
	$out+=$escape($value.lighter.nickname);
	$out+='</p> <p class="user-mes">';
	$out+=$escape($value.content);
	$out+='</p> </div> </div> <a href="javascript:;" class="more-mes"></a> </div> ';
	});
	return new String($out);
	});

/***/ }
/******/ ]);