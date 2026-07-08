class PlayerComponent {
  constructor(scheduleDate, schedule, interstitialVideoIds) {
    this.scheduleDate = scheduleDate
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
    return currentHour.replace(' AM', ' am').replace(' PM', ' pm')
  }

  currentShow() {
    const currentTime = this.timeFormatted(new Date())
    return this.getContentForTime(currentTime)
  }

  nextShow() {
    const currentTime = this.currentTime()
    currentTime.setMinutes(currentTime.getMinutes() + 30, 0, 0)
    const time = this.timeFormatted(currentTime)
    return this.schedule[time]
  }

  getContentForTime(targetTime) {
    const pastTimes = Object.keys(this.schedule).filter((scheduleTime) => {
      const scheduleTimeFixed = scheduleTime.replace('am', ' am').replace('pm', ' pm')
      return Date.parse('01/01/2011 '+ scheduleTimeFixed) <= Date.parse('01/01/2011 ' + targetTime)
    })
    const content = this.schedule[pastTimes[pastTimes.length - 1]]
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
    this.initClickEvents()
  }

  randomNumberBetween(min, max) {
    return Math.floor(Math.random() * (max - min + 1) + min)
  }

  playInitialVideo() {
    const rand = Math.random()
    if (rand < 0.9) {
      const { videoID } = this.currentShow()
      this.currentVideoID = videoID
      const startTimeSec = this.randomNumberBetween(30, 240)
      this.attachIframe(videoID, startTimeSec)
    } else {
      const randomVideoId = this.getRandomInterstitialVideoId()
      const startTimeSec = this.randomNumberBetween(2, 30)
      this.attachIframe(randomVideoId, startTimeSec)
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
    this.loadNowPlayingData()
  }

  loadNowPlayingData() {
    const { time, show, episode } = this.currentShow()
    const titleContainer = document.getElementById('now-playing__title')
    const subTitleContainer = document.getElementById('now-playing__subtitle')
    const timeContainer = document.getElementById('time__container')
    document.title = `YTV25 | ${show}`
    titleContainer.innerHTML = show
    subTitleContainer.innerHTML = episode
    timeContainer.innerHTML = time
  }

  initClickEvents() {
    const reportButton = document.getElementById('report-content')
    reportButton.addEventListener('click', (event) => {
      this.reportContent()
    })
  }

  reportContent() {
    const { time, show, episode, videoID } = this.currentShow()
    const issuePath = `https://github.com/imRohan/YTV-Schedule-Archives/issues/new?title=[${this.scheduleDate}] ${show}&body=${this.scheduleDate} @ ${time}: ${show}, ${episode}, incorrect video id: ${videoID}.&labels=Incorrect Content&assignees=imRohan`
    window.open(issuePath, '_blank').focus()
  }
}

window.PlayerComponent = PlayerComponent
