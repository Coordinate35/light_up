function Video(videoElem) {
    this.videoElem = videoElem;
    this.videos = [];
    this.curVideo = 0;
}

Video.prototype.init = function (videoData) {
    var videoElem = this.videoElem,
        self = this;
    this.videos.push(videoData[0]);
    videoElem.addEventListener('canplaythrough', function (e) {
        if (self.curVideo === 1) {
            $('.loading-container').addClass('hide');
        }
    }, false);
    videoElem.src = videoData[0].save_key;
    videoElem.load();
};

Video.prototype.append = function (videoData) {
    this.videos.push(videoData[0]);
};

Video.prototype.next = function () {
    var videoElem = this.videoElem;
    this.curVideo += 1;
    videoElem.src = this.videos[this.curVideo].save_key;
    videoElem.load();
};

module.exports = Video;
