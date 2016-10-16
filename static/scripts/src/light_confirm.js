require('../../tpl/modules/light_confirm/light_confirm.css');
var light_confirm = require('../../tpl/modules/light_confirm/light_confirm.tpl');

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
