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
