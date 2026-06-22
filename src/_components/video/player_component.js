class PlayerComponent {
  constructor(schedule, interstitialVideoIds) {
    this.schedule = schedule
    this.interstitialVideoIds = interstitialVideoIds
    this.player = null
    this.currentVideoID = null
  }

  currentTime() {
    const currentTime = new Date()
    const currentMinutes = currentTime.getMinutes()
    if(currentMinutes < 30) {
      currentTime.setMinutes(0,0,0)
    } else {
      currentTime.setMinutes(30,0,0)
    }
    return currentTime
  }

  timeFormatted(time) {
    const currentHour = time.
      toLocaleString('en-US', { hour: 'numeric', hour12: true,
                                minute: '2-digit' })
    return currentHour.replace(' AM', 'am').replace(' PM', 'pm')
  }

  currentShow() {
    const time = this.timeFormatted(this.currentTime())
    return this.getContentForTime(time)
  }

  nextShow() {
    const currentTime = this.currentTime()
    currentTime.setMinutes(currentTime.getMinutes() + 30, 0, 0)
    const time = this.timeFormatted(currentTime)
    return this.schedule[time]
  }

  getContentForTime(time) {
    const content = this.schedule[time]
    const { show, videoID } = content
    if(show && videoID) {
      return content
    } else {
      return { show: "No Content", episode: "Sorry folks!", videoID: "7xmtQdDQ2ik" }
    }
  }

  loadPlayer() {
    this.playInitialVideo()
    this.loadNowPlayingData()
  }

  playInitialVideo() {
    const rand = Math.random()
    if (rand < 0.6) {
      const { videoID } = this.currentShow()
      this.currentVideoID = videoID
      this.attachIframe(videoID, 30)
    } else {
      const randomVideoId = this.getRandomInterstitialVideoId()
      this.attachIframe(randomVideoId, 5)
    }
  }

  attachIframe(videoID, start) {
    this.player = new YT.Player('player', {
      height: '390',
      width: '640',
      videoId: videoID,
      events: {
        'onStateChange': this.onPlayerStateChange,
      },
      playerVars: {
        start,
        'mute': 1,
        'controls': 0,
        'autoplay': 1,
        'rel': 0,
        'showinfo': 0,
        'playsinline': 1,
        'color':'white',
      },
    })
  }

  onPlayerStateChange(event) {
    switch(event.data) {
      case YT.PlayerState.PAUSED:
        window.player.handlePausedState(event)
        break;
      case YT.PlayerState.ENDED:
        window.player.handleEndedState()
        break;
    }

  }

  handlePausedState(event) {
    if (event.target.isMuted()) {
      event.target.unMute();
      event.target.playVideo();
      const notice = document.getElementById('video__notice')
      notice.style.display = 'none'
    }
  }

  handleEndedState() {
    const { videoID } = this.currentShow()
    if (this.currentVideoID === videoID) {
      this.playInterstitialVideo()
    } else {
      this.playNewShow()
    }
  }

  getRandomInterstitialVideoId() {
   const randomIndex = Math.floor(Math.random() * this.interstitialVideoIds.length)
   return this.interstitialVideoIds[randomIndex]
  }

  playInterstitialVideo() {
   const randomVideoId = this.getRandomInterstitialVideoId()
   this.player.loadVideoById(randomVideoId)
  }

  playNewShow() {
    const { videoID } = this.currentShow()
    this.player.loadVideoById(videoID)
    this.currentVideoID = videoID
  }

  loadNowPlayingData() {
    const { show, episode } = this.currentShow()
    const titleContainer = document.getElementById('now-playing__title')
    const subTitleContainer = document.getElementById('now-playing__subtitle')
    const timeContainer = document.getElementById('time__container')
    document.title = `YTV Archive Channel | ${show}`
    titleContainer.innerHTML = show
    subTitleContainer.innerHTML = episode
    timeContainer.innerHTML = this.timeFormatted(this.currentTime())
  }
}

window.PlayerComponent = PlayerComponent
