{{each logs}}
<div class="message-item">
    <!-- <div class="user-potrait">
        <img src="">
    </div> -->
    <input type="hidden" value="{{$value.lighter.user_id}}">
    <img class="user-potrait" src="{{$value.lighter.portrait}}">
    <div class="mes-box">
        <div class="mes-container">
            <p class="username">{{$value.lighter.nickname}}</p>
            <p class="user-mes">{{$value.content}}</p>
        </div>
    </div>
    <a href="javascript:;" class="more-mes"></a>
</div>
{{/each}}