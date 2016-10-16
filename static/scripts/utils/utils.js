window.Hybrid = window.Hybrid || {};
var bridgePostMsg = function(url) {
	if ($.os.ios) {
		window.location = url;
	} else {
		var ifr = $('<iframe style="display: none;" />');
		$(ifr).attr('src', url);
		$('body').append(ifr);
		setTimeout(function() {
			ifr.remove();
		}, 1000);
//		$(ifr).on('load', function() {
//			console.log('success')
//			ifr.remove();
//		})
	}
};
var _getHybridUrl = function(params) {
	var k, paramStr = '',
		url = 'lightupjs://';
	url += JSON.stringify(params)
	return url;
};
var requestHybrid = function(params) {
	//生成唯一执行函数，执行后销毁
	var tt = (new Date().getTime());
	var t = 'hybrid_' + tt;
	var tmpFn;

	//处理有回调的情况
	if (params.call) {
		tmpFn = params.call;
		params.call = t;
		window[t] = function(data) {
			tmpFn(data);
			delete window[t];
		}
	}
	bridgePostMsg(_getHybridUrl(params));
};
//获取版本信息，约定APP的navigator.userAgent版本包含版本信息：lightupjs/xx.xx.xx
var getHybridInfo = function() {
	var platform_version = {};
	var na = navigator.userAgent;
	var info = na.match(/lightupjs\/\d\.\d\.\d/);

	if (info && info[0]) {
		info = info[0].split('/');
		if (info && info.length == 2) {
			platform_version.platform = info[0];
			platform_version.version = info[1];
		}
	}
	return platform_version;
};

module.exports = {
	bridgePost: bridgePostMsg,
	requestHybrid: requestHybrid,
	getHybridInfo: getHybridInfo
}