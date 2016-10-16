# light up 接口文档

[测试环境链接](http://devlightup.yishun.co:61336)
[生产环境http链接](http://www.lightupforu.com:61336)
[生产环境https链接](https://www.lightupforu.com:61335)

发送的数据以表单的形式,每个字段的内容是以json格式
所有数据返回都以json的形式


失败的请求，返回的数据中只有error字段

说明:为了避免key保存在客户端，同时保证数据的一致性，凡是涉及到要上传文件，必需先请求“××××请求的接口”，把上传文件相关的信息告诉服务器，然后服务器会生成相关的policy和signature，客户端直接拿这两个参数去请求又拍云的服务器把文件上传上去，如果成功了，在请求（确认×××××的接口），让上传的文件生效。



## 发起注册请求接口

POST /v1/account/register

说明：请求此接口成功后，帐号并未生效，必须通过短信的验证之后才会生效。请求此接口后会向用户发送验证短信

参数

参数名 | 说明
---:|:---
phone_number | 必需，用户的电话号码，设定只能是11位

返回：

状态码 200
```json
{
    "status": "new a user, sms sent successfully",
    "data": {}
}
```

## 短信验证接口

POST /v1/account/validate_sms

说明：此接口用于注册和修改密码的短信验证码验证

参数:

参数名 | 说明
---:|:---
phone_number|必需，用户的电话号码，设定只能11位
validate_code|必需，用户填写的状态码手机接收到的短信验证码，设定只能在100000～999999之间
validate_type|必需，验证的场景，决定是在注册的时候验证还是在修改密码的时候验证，必'register'和'change_password'之间一个

返回：

状态码200
```json
{
    "data": {
        "user_id": "5702a05c7b6ef053a330e8c3",
        "access_token": "e030e6a906e19fc297318277bba7a6f2"
    }
}
```

## 登陆接口

POST /v1/account/login

参数:

参数名 | 说明
---:|:---
phone_number|必需，用户的电话号码，设定只能11位
login_type | 必需，决定登陆的方式，只能为"password“或者"access_token"
password | 可选，与access_token二者选一,设定为6-30位
access_token | 可选，与password二选一

返回:

状态码200

```json
{
    "data": {
        "wechat_uid": "",
        "weibo_uid": "",
        "nickname": "Coordinate35",
        "_id": "5702a4a5589613964cafdc76",
        "love_sex": "",
        "phone_number": "15172354423",
        "access_token": "2d60640343e8ecd0421203ba8a43d2e8",
        "birthday": "",
        "weibo_nickname": "",
        "location": "",
        "wechat_nickname": "",
        "sex": "",
        "portrait": ""
    }
}
```

## 发起更改密码意愿接口

POST /v1/account/change_password_request

参数

参数名|说明
---:|:----
phone_number|必需，用户的电话号码，设定只能为11位

返回:

会向用户发送手机短信

状态码200

{"status":"sms sent successfully","data":{}}


## 设置密码接口

说明:必需先发送更改密码意愿接口

POST /v1/account/change_password

参数

参数名|说明
:---:|:---
phone_number| 必需，用户的电话号码，设定为只能11位
password| 必需，用户更改后的密码，设定为6到30位

返回：

状态码 200

```json
{
    "status": "change password successfully",
    "data": {}
}
```

## 更改个人信息接口

说明：用于更改个人信息

POST /v1/account/change_personal_info

参数

参数名|说明
:---:|:--
user_id | 必需，用户的id，限定为24位
access_token | 必需，用户获取信息的凭证，限定为32位
personal_info | 必需，用户的个人信息，是一个

返回：
状态码 200

"{\"status\":\"change personal_info successfully\"}"

## 刷新用户access_token接口

POST /v1/account/refresh_access_token

参数|说明
:---:|:--
user_id|必须，用户的id，限定24位
access_token|必需，用户当前的用户凭证，限定32位

返回:
状态码 200

```JSON
{
    "data": {
        "access_token": "87ec2279c7b10a1c6f0a41e60349aa46"
    }
}
```

## 获取用户信息接口

POST /v1/account/get_user_info

参数 | 说明
---:|:---
user_id|必需，当前用户id，限定24位
access_token | 必需，当前用户的凭证，限定32位
target_id|必需，要获取的用户的id,限定24位

返回:
状态码 200

```json
{
    "data": {
        "wechat_uid": "",
        "value_concept_light_number": 0,
        "weibo_uid": "",
        "nickname": "Coordinate35",
        "sex": "",
        "love_sex": "",
        "emotion_experience_light_number": 0,
        "birthday": "",
        "phone_number": "15172354423",
        "access_token": "87ec2279c7b10a1c6f0a41e60349aa46",
        "age": 0,
        "weibo_nickname": "",
        "location": "",
        "wechat_nickname": "",
        "basic_info_light_number": 0,
        "portrait": "",
		"basic_info_complete": true,
		"emotion_experience_complete": true,
		"value_concept_complete": true
    }
}
```

## 上传头像请求接口

POST /v1/account/upload_portrait_request

save_key规范: /portrait/[user_id]-[timestamp].[suffix]

参数

参数名|说明
---:|:---
user_id |必需，用户的id，限定24位
access_token|必需，用户的凭证，限定32位
save_key|必需，上传图片在右拍云的路径，限定小于255位
expiration|必需，上传图片的过期时间，限定10位整数
bucket|必需，上传到又拍云的空间名

```json
{
	"user_id": "...",
	"access_token": "...",
	"save_key": "...",
	"expiration": ...,
	"bucket": "..."
}
```

返回

状态码 200

```json
{
    "data": {
        "policy": "eyJleHBpcmF0aW9uIjoiMjIyMjIyMjIyMiIsImJ1Y2tldCI6InBvcnRyYWl0Iiwic2F2ZS1rZXkiOiJcL0Nvb3JkaW5hdGUzNS5qcGcifQ==",
        "signatrue": "12166f91149199f38ad9bced889981a7"
    }
}
```

## 让新头像生效接口

POST /v1/account/upload_portrait_confirm

参数名|说明
---:|:---
user_id |必需，用户的id，限定24位
access_token |必需，用户的凭证，限定32位

```json
{
    "status": "update portrait successfully",
    "data": {}
}
```

返回

## 更新device_token接口 （已废弃）

POST /v1/account/refresh_device_token

参数名|说明
---:|:---
user_id|必需，用户id，限定24位
access_token |必需，用户的凭证，限定32位
device_token |必需，用户的新devive_token

状态码 200

```json
{
    "status": "update device_token successfully",
    "data": {}
}
```

## 更新device_token库接口

POST /v1/account/refresh_device_token_lib

参数名|说明
---:|:---
user_id|可选，用户id，限定24位
access_token |可选，有user_id的情况下必填，用户的凭证，限定32位
device_token |必需，用户的新devive_token

状态码 200

```json
{
    "status": "update device_token successfully",
    "data": {}
}
```

## 获取随机问题接口
POST /v1/procedure/get_random_questions

参数

参数名|说明
---:|:--
user_id|必须，用户的id，限定24位
access_token|必需，用户当前的凭证，限定32位
class|必须，问题的分类,限定为basic_info,emotion_experience,value_concept
limit|必须，获取问题的条数，限定为3

返回
状态码 200

```json
{
    "data": {
		"questions" : [
        	{
            	"problem_content": "Are you gay",
            	"problem_id": "5703afcc4ed17677e64dd791"
        	},
        	{
        	    "problem_content": "Where are you from",
        	    "problem_id": "5703afeb401c8dc22de77771"
        	},
        	{
        	    "problem_content": "Have you sex",
        	    "problem_id": "5703b00439d5448cf19e4540"
        	}
    	]
	}
}
```

## 获取问题接口
POST /v1/account/get_questions

参数

参数名|说明
---:|:--
user_id|必须，用户的id，限定24位
access_token|必需，用户当前的凭证，限定32位
class|必须，问题的分类,限定为basic_info,emotion_experience,value_concept

返回
状态码 200

```json
{
    "data": {
		"questions" : [
        	{
            	"problem_content": "Are you gay",
            	"problem_id": "5703afcc4ed17677e64dd791"
        	},
        	{
        	    "problem_content": "Where are you from",
        	    "problem_id": "5703afeb401c8dc22de77771"
        	},
        	{
        	    "problem_content": "Have you sex",
        	    "problem_id": "5703b00439d5448cf19e4540"
        	}
    	]
	}
}
```

## 发起上传视频，音频请求接口

POST /v1/media/upload_request

save_key规范: /[media_class]/[user_id]-[10位timestamp].[suffix]

参数


### 上传音频集请求
说明：此接口请求成功后，并不会立即生效

参数名 | 说明
---:|:---
user_id | 必须,用户的id，限定为24位
sex | 必须，用户的性别。限定为male或female
access_token | 必需，用户的凭证，限定为32位
file_type | 必需，用户上传文件类型，只能为audio获video
audio_class|必须，音频文件的问题类型，目前只能为basic_info
question_arr|必需，抽到问题的一个数组,限定只能有3个元素

questioin_arr含有的参数

参数名 | 说明
---:|:---
save_key | 必须，保存文件在又拍云空间的路径，限定小于255位
question_id | 必须，回答的问题的问题id，限定为24位
question_order | 必须,该问题在问题集中的次序，为一位整数

例子

```JSON
	{
		"user_id": "...",
		"sex": "...",
		"access_token": "...",
		"file_type": "...",
		"audio_class": "...",
		"question_arr": [
			{
				"save_key": "...",
				"question_id": "...",
				"question_order": ...,
			},
			...
		]
	}
```

返回

状态码 200

```json
{
    "data": {
        "expiration": 1459946290,
        "bucket": "audio",
        "audio_buffer_id": "5703b1b2ed2139366e73b717",
        "audios": [
            {
                "question_order": 1,
                "policy": "eyJleHBpcmF0aW9uIjoxNDU5OTQ2MjkwLCJidWNrZXQiOiJhdWRpbyIsInNhdmUta2V5IjoiaHR0cDpcL1wvd3d3LmJhaWR1LmNvbSJ9",
                "signature": "4ff80fb7c1d691aba3b964ce1f9b91aa"
            },
            {
                "question_order": 2,
                "policy": "eyJleHBpcmF0aW9uIjoxNDU5OTQ2MjkwLCJidWNrZXQiOiJhdWRpbyIsInNhdmUta2V5IjoiaHR0cDpcL1wvd3d3LmJhaWR1LmNvbSJ9",
                "signature": "4ff80fb7c1d691aba3b964ce1f9b91aa"
            },
            {
                "question_order": 3,
                "policy": "eyJleHBpcmF0aW9uIjoxNDU5OTQ2MjkwLCJidWNrZXQiOiJhdWRpbyIsInNhdmUta2V5IjoiaHR0cDpcL1wvd3d3LmJhaWR1LmNvbSJ9",
                "signature": "4ff80fb7c1d691aba3b964ce1f9b91aa"
            }
        ]
    }
}
```

### 上传视频请求

说明：此接口请求成功后，并不会生效

参数名 | 说明
---:|:---
user_id | 必须,用户的id，限定为24位
access_token | 必需，用户的凭证，限定为32位
sex | 必须，用户的性别。限定为male或female
file_type | 必需，用户上传文件类型，只能为audio获video
video_class|必须，音频文件的问题类型，目前只能为emotion_experience, value_concept
questions|必需，抽到问题的一个数组,限定只能有3个元素
save_key | 必须，保存文件在又拍云空间的路径，限定小于255位

questions含有的参数
参数名 | 说明
---:|:---
question_id | 必须，回答的问题的问题id，限定为24位
question_order | 必须,该问题在问题集中的次序，为一位整数


例子

```JSON
	{
		"user_id": "...",
		"access_token": "...",
		"sex": "...",
		"file_type": "...",
		"video_class": "...",
		"save_key": "...",
		"questions": [
			{
				"question_id": "...",
				"question_order": ...,
			},
			...
		]
	}
```

返回

状态码 200

```json
{
    "data": {
        "bucket": "video",
        "policy": "eyJleHBpcmF0aW9uIjoxNDU5OTQ2NjUwLCJidWNrZXQiOiJ2aWRlbyIsInNhdmUta2V5Ijoid3d3LmJhaWR1LmNvbSJ9",
        "expiration": 1459946650,
        "signature": "08960b58f5f415d283b1619c1dd2761a",
        "video_buffer_id": "5703b31aed2139366e73b718"
    }
}
```

## 让上传的视频或音频生效接口

POST /v1/media/confirm

参数

参数名|说明
---:|:---
user_id|必需，用户的id，限定为24位
access_token|必需，用户的凭证，限定32位
file_type|必需，媒体文件类型，限定为audio或video
file_id|必需，上传媒体文件申请后获得的id，限定为24位

```JSON
{
	"user_id": "...",
	"access_token": "...",
	"file_type": "...",
	"file_id": "...'
}
```

返回

状态码 200
```json
{
    "status": "operate successfully",
    "data": {}
}
```

## 直接上传视频，音频接口

POST /v1/media/upload_media

save_key规范: /[media_class]/[user_id]-[10位timestamp].[suffix]

参数


### 上传音频集请求
说明：此接口请求成功后，并不会立即生效

参数名 | 说明
---:|:---
user_id | 必须,用户的id，限定为24位
sex | 必须，用户的性别。限定为male或female
access_token | 必需，用户的凭证，限定为32位
file_type | 必需，用户上传文件类型，只能为audio获video
audio_class|必须，音频文件的问题类型，目前只能为basic_info
question_arr|必需，抽到问题的一个数组,限定只能有3个元素

questioin_arr含有的参数

参数名 | 说明
---:|:---
save_key | 必须，保存文件在又拍云空间的路径，限定小于255位
question_id | 必须，回答的问题的问题id，限定为24位
question_order | 必须,该问题在问题集中的次序，为一位整数

例子

```JSON
	{
		"user_id": "...",
		"sex": "...",
		"access_token": "...",
		"file_type": "...",
		"audio_class": "...",
		"question_arr": [
			{
				"save_key": "...",
				"question_id": "...",
				"question_order": ...,
			},
			...
		]
	}
```

返回

状态码 200

```json
{
	"status": "set upload file successfully",
    "data": {}
}
```

### 上传视频请求

说明：此接口请求成功后，并不会生效

参数名 | 说明
---:|:---
user_id | 必须,用户的id，限定为24位
access_token | 必需，用户的凭证，限定为32位
sex | 必须，用户的性别。限定为male或female
file_type | 必需，用户上传文件类型，只能为audio获video
video_class|必须，音频文件的问题类型，目前只能为emotion_experience, value_concept
questions|必需，抽到问题的一个数组,限定只能有3个元素
save_key | 必须，保存文件在又拍云空间的路径，限定小于255位

questions含有的参数
参数名 | 说明
---:|:---
question_id | 必须，回答的问题的问题id，限定为24位
question_order | 必须,该问题在问题集中的次序，为一位整数


例子

```JSON
	{
		"user_id": "...",
		"access_token": "...",
		"sex": "...",
		"file_type": "...",
		"video_class": "...",
		"save_key": "...",
		"questions": [
			{
				"question_id": "...",
				"question_order": ...,
			},
			...
		]
	}
```

返回

状态码 200

```json
{
	"status": "set upload file successfully",
    "data": {}
}
```

## 根据性取向获取一位嘉宾的id

POST /v1/procedure/get_user_id_by_love_sex

参数

参数名|说明
---:|:---
user_id|必需，用户的id，限定为24位
access_token|必需，用户的凭证，限定32位
love_sex |必需，用户的性取向，限定为male或female,或both

```json
{
	"user_id": "...",
	"access_token": "...",
	"love_sex": "..."
}

返回

```json
{
    "data": {
        "target_id": "5702a4a5589613964cafdc76",
        "have_light_number": 0
    }
}
```

## 根据性取向获取多位嘉宾的id

POST /v1/procedure/get_user_ids_by_love_sex

参数

参数名|说明
---:|:---
user_id|必需，用户的id，限定为24位
access_token|必需，用户的凭证，限定32位
love_sex |必需，用户的性取向，限定为male或female,或both

```json
{
	"user_id": "...",
	"access_token": "...",
	"love_sex": "..."
}

返回

```json
{
    "data": {
        "user_ids": [
            {
                "target_id": "5702a4a5589613964cafdc76",
                "have_light_number": 0
            }
        ]
    }
}
```

说明:have_light_number表明现在该用户已经对改嘉宾点亮了多少盏灯

## 获取嘉宾音频接口

POST /v1/procedure/get_media

参数

参数名 | 说明
---:|:---
user_id | 必需,用户的id，限定为24位
access_token | 必需，用户的凭证,限定32位
target_id | 必需，用户的性取向，限定为male或female
class | 必需，嘉宾音频信息的分类，限定为basic_info
file_type |必需， 固定为audio

```json
{
	"user_id": "...",
	"access_token": "...",
	"target_id": "...",
	"audio_class": "...",
	"file_type": "audio"
}
```

返回

状态码 200

```json
{
	"data": {
		[
			{
				"save_key": "...",
				"question_id": "...",
				"question_content": "...",
				"question_order": "..."
			},
			...
		]
	}
}
```

## 获取嘉宾视频信息

POST /v1/procedure/get_media

参数

参数名|说明
---:|:---
user_id|必需，用户的id，限定为24位
access_token | 必需，用户的凭证，限定32位
target_id|必需，嘉宾用户的id，限定为24位
class | 必须，视频的模块，限定为emotion_experience或value_concept
file_type | 必需，固定为video

```json
{
	"user_id": "...",
	"access_token": "...",
	"target_id": "...",
	"class": "...",
	"file_type": "video"
}
```

返回

状态码 200

```json
{
	"data": {
		"save_key": "...",
		"questions": [
			{
				"question_id": "...",
				"question_order": "...",
				"question_content"
			},
			...
		]
	}
}
```

## 点灯接口

POST /v1/procedure/light_up

参数

参数名|说明
---:|:---
user_id|必需，用户的id,限定为24位
access_token|必需，用户的凭证，限定为32位
target_id|必需，被点灯的嘉宾id，限定为24位
order|必需，被点的灯的序号，限定为1,2,3
light_status|必需，被操作的灯的最后状态，1表示亮，0表示灭

```json
{
	"user_id": "...",
	"access_token": "...",
	"target_id": "...",
	"order": ...,
	"light_status": ...
}
```

返回

状态码 200

```json
{
    "data": {},
    "status": "light up successfully"
}
```

## 记录该用户已经看过该嘉宾接口
POST /v1/procedure/log_have_seen

参数

参数名|说明
---:|:---
user_id|必需，用户的id,限定为24位
access_token|必需，用户的凭证，限定为32位
target_id|必需，被看的嘉宾id，限定为24位

```json
{
	"user_id": "...",
	"access_token": "...",
	"target_id": "..."
}
```

返回

状态码 200

```json
{
    "status": "Accept",
    "data": {}
}
```

## 获取消息接口

POST /v1/procedure/get_message

参数

参数名|说明
---:|:---
user_id|用户的id
access_token|用户的凭证

返回

状态码 200

```json
{
    "data": {
        "logs": [
            {
                "content": "我为你亮了三盏灯，快来联系我吧～",
                "lighter": {
					"user_id": "..."
                    "portrait": "",
                    "nickname": "Coordinate35"
                },
                "time": 1460900510
            }
        ]
    }
}
```

## 删除用户接口

说明：此接口不投入生产，只用于方便测试用！！！

POST /v1/account/delete_user

参数

参数名|说明
---:|:---
phone_number|必须，为用户的电话号码

返回
{"error": "..."}
{"status': "..."}

## 按类别删除个人媒体文件接口

POST /v1/media/delete_media

参数

参数名|说明
---:|:---
user_id|必需，用户的id，限定为24位
access_token|必需，用户的凭证，限定32位
file_type|必需，媒体文件类型，限定为audio或video
class|必需，上传文件所属的阶段类型，比如basic_info

```JSON
{
	"user_id": "...",
	"access_token": "...",
	"file_type": "...",
	"class": "...'
}
```

返回

状态码 200
```json
{
    "status": "operate successfully",
    "data": {}
}
```


