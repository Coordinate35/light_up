<img class="user-potrait" src="{{portrait}}"></img>
<div class="user-info">
    <p>
        <span class="username">{{nickname}}</span>
        {{if sex === 'male'}}
            <img src="images/video_index/ic_me_male@2x.png" class="sex">
        {{else}}
            <img src="images/video_index/ic_me_female@2x.png" class="sex">
        {{/if}}
    </p>
    <p>
        <span class="age">{{age}}</span>
        {{if sex === 'male'}}
            <span class="sex-orientation">男性</span>
        {{else}}
            <span class="sex-orientation">女性</span>
        {{/if}}
        <span class="location">{{location}}</span>
    </p>
</div>