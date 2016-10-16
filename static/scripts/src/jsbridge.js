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
