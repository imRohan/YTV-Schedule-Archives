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
    const { videoID } = content
    if(videoID) {
      return content
    } else {
      return { show: "No Content", episode: "N/a", videoID: "7xmtQdDQ2ik" }
    }
  }

  loadPlayer() {
    this.attachIframe()
    this.loadNowPlayingData()
  }

  attachIframe() {
    const { videoID } = this.currentShow()
    this.player = new YT.Player('player', {
      height: '390',
      width: '640',
      videoId: videoID,
      events: {
        'onStateChange': this.onPlayerStateChange,
      },
      playerVars: {
        'start': 30,
        'mute': 1,
        'controls': 0,
        'autoplay': 1,
        'rel': 0,
        'showinfo': 0,
        'playsinline': 1,
        'color':'white',
      },
    })
    this.currentVideoID = videoID
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

  playInterstitialVideo() {
   const randomIndex = Math.floor(Math.random() * this.interstitialVideoIds.length)
   const randomVideoId = this.interstitialVideoIds[randomIndex]
   this.player.loadVideoById(randomVideoId)
  }

  playNewShow() {
    const videoID = this.currentVideoID
    this.player.loadVideoById(videoID)
    this.currentVideoID = videoID
  }

  loadNowPlayingData() {
    const { show, episode } = this.currentShow()
    const titleContainer = document.getElementById('now-playing__title')
    const subTitleContainer = document.getElementById('now-playing__subtitle')
    const timeContainer = document.getElementById('time__container')
    titleContainer.innerHTML = show
    subTitleContainer.innerHTML = episode
    timeContainer.innerHTML = this.timeFormatted(this.currentTime())
  }
}

window.PlayerComponent = PlayerComponent
