require('../../tpl/modules/reminder/reminder_modal.css');
var reminder = require('../../tpl/modules/reminder/reminder.tpl');

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