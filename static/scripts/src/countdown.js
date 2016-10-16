function Countdown() {

}

function countdown(destTime) {
    var srcTime = (new Date()).getTime();
    var diffTime = Math.floor((destTime - srcTime) / 1000);
    var hours = Math.floor(diffTime / 3600);
    hours = (hours < 10) ? '0' + hours : hours;
    var minutes = Math.floor((diffTime - hours * 3600) / 60);
    minutes = (minutes < 10) ? '0' + minutes : minutes;
    var seconds = diffTime - hours * 3600 - minutes * 60;
    seconds = (seconds < 10) ? '0' + seconds : seconds;
    var time = hours + ':' + minutes + ':' + seconds;
    // console.log(destTime, hours, minutes, seconds);
    $('.countdown').text(time);
    if (hours === 0 && minutes === 0 && seconds === 0) {
        window.location.href = window.location.reload(true);
        return;
    }
    // console.log(diffTime, hours, minutes, seconds);
    setTimeout(function () {
        countdown(destTime);
    }, 1000);
}

Countdown.prototype.init = function (time) {
    this.destTime = (new Date(time)).getTime();
    // console.log(time, typeof time, this.destTime);
};

Countdown.prototype.countdown = function () {
    countdown(this.destTime);
};

module.exports = Countdown;
