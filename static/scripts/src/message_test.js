var Jsbridge = require('./jsbridge');
var Reminder = require('./reminder');

var messgeResults = require('../../tpl/message.tpl');

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

$('.message-item').on('tap', function (e) {
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
