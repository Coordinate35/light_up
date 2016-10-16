module.exports = function(){
	var url = location.search; 
	var theRequest = new Object();
	if (url.indexOf("?") != -1) {
		url = decodeURI(url);
		var str = url.substr(1);
		strs = str.split("&");	strs = str.split("&");	strs = str.split("&");
		for(var i = 0; i < strs.length; i ++) {
			theRequest[strs[i].split("=")[0]]=unescape(strs[i].split("=")[1]);
		}
	}
	return theRequest;
};