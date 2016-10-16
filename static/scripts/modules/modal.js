require('../../tpl/modules/modal/modal.css');
var tpl = require('../../tpl/modules/modal/modal.tpl');

function Modal() {
	this.isShow = false;
	this.$ele = null;
	this.$overLayer = null;
}

Modal.prototype.show = function(content, timeout) {
	var _this = this;
	if (_this.isShow === true) {
		return;
	}
	_this.$overLayer.addClass('active');
	_this.$ele.animate({"display":"block"},100,function(){
		$(this).addClass('modal-in');
		_this.isShow = true;
	});
};

Modal.prototype.hide = function() {
	var _this = this;
	if (_this.isShow === false) {
		return;
	}
	_this.$ele.removeClass('modal-in');
	_this.$ele.one('transitionend', function() {
		_this.$ele.css({
			"display": "none"
		});
		_this.$overLayer.removeClass('active');
		_this.isShow = false;
	});
};
Modal.prototype.init = function(content) {
	var _this = this;
	content = content || '';
	$('body').append(tpl({
		content: content
	}));
	_this.$ele = $('.overLayer .modal');
	_this.$overLayer = $('.overLayer');
	
	_this.$ele.on('tap',function(e){
		e.stopPropagation();
	})
	
	_this.$overLayer.on('tap', function(e) {
		if (_this.isShow === true) {
			_this.hide();
		}
	});
};

module.exports = Modal;