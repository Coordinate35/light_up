function Audio(audioElem) {
    this.curAudio = 0;
    this.audios = [];
    this.audioElem = audioElem;
    this.audioTotal = 0;
    this.state = 'pause';
    this.canplay = false;
}

Audio.prototype.init = function (audioArr) {
    var self = this;
    this.audioElem.addEventListener('canplay', function (e) {
        self.audioTotal = parseInt(e.target.duration);
        self.canplay = true;
        // console.log(self);
    }, false);
    for (var i = 0; i < audioArr.length; i++) {
        var start = audioArr[i].question_order - 1;
        if (start === 0) {
            $('.tape-question-content').text(audioArr[i].question_content);
            this.audioElem.src = audioArr[i].save_key;
            this.audioElem.load();
        }
        this.audios.splice(start, 0, audioArr[i]);
    }
    // console.log(this.audios);
    this.audioElem.addEventListener('timeupdate', function (e) {
        var curTime = parseInt(e.target.currentTime);
        var playpercent = parseInt(curTime / self.audioTotal * 100) + '%';
        if (curTime === self.audioTotal) {
            self.state = 'pause';
            $('#stop-audio').addClass('hide');
            $('#play-audio').removeClass('hide');
        }
        $('.tape-runtime-text').text(curTime);
        $('.tape-runtime').width(playpercent);
    }, false);
};

Audio.prototype.play = function () {
    this.state = 'play';
    this.audioElem.play();
};

Audio.prototype.pause = function () {
    this.state = 'pause';
    this.audioElem.pause();
};

Audio.prototype.next = function () {
    $('#stop-audio').addClass('hide');
    $('#play-audio').removeClass('hide');
    this.state = 'pause';
    this.canplay = false;
    // console.log(this);
    if (this.curAudio === this.audios.length - 1) {
        this.curAudio = 0;
    } else {
        this.curAudio += 1;
    }
    var curAudio = this.audios[this.curAudio];
    $('.tape-question-content').text(curAudio.question_content);
    this.audioElem.src = curAudio.save_key;
    this.audioElem.load();
};

Audio.prototype.previous = function () {
    $('#stop-audio').addClass('hide');
    $('#play-audio').removeClass('hide');
    this.state = 'pause';
    this.canplay = false;
    // console.log(this);
    if (this.curAudio === 0) {
        this.curAudio = this.audios.length - 1;
    } else {
        this.curAudio -= 1;
    }
    var curAudio = this.audios[this.curAudio];
    $('.tape-question-content').text(curAudio.question_content);
    this.audioElem.src = curAudio.save_key;
    this.audioElem.load();
};

module.exports = Audio;
