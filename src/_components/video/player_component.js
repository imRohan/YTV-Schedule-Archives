class PlayerComponent {
  constructor(scheduleDate, schedule, interstitialVideoIds) {
    this.scheduleDate = scheduleDate
    this.schedule = schedule
    this.interstitialVideoIds = interstitialVideoIds
    this.player = null
    this.currentVideoID = null
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

  getContentForTime(targetTime) {
    const pastTimes = Object.keys(this.schedule).filter((scheduleTime) => {
      const scheduleTimeFixed = scheduleTime.replace('am', ' am').replace('pm', ' pm')
      return Date.parse('01/01/2011 '+ scheduleTimeFixed) <= Date.parse('01/01/2011 ' + targetTime)
    })
    const content = this.schedule[pastTimes[pastTimes.length - 1]]
    const { time, show, videoID } = content
    if(show && videoID) {
      return content
    } else {
      return { time, show: "No Content", episode: "Sorry folks!", videoID: "7xmtQdDQ2ik" }
    }
  }

  loadPlayer() {
    this.loadChannelNumber()
    this.playInitialVideo()
    this.loadNowPlayingData()
    this.initClickEvents()
  }

  randomNumberBetween(min, max) {
    return Math.floor(Math.random() * (max - min + 1) + min)
  }

  playInitialVideo() {
    const { time, videoID } = this.currentShow()
    const elapsedSeconds = this.getElapsedTimeSeconds(time)
    this.attachIframe(videoID, elapsedSeconds)
    this.currentVideoID = videoID
  }

  getElapsedTimeSeconds(scheduleTime) {
    const currentTime = new Date()
    const currentMinutes = currentTime.getMinutes()
    const currentTimeSlot = this.convertScheduleTime(scheduleTime)
    const currentTimeSlotStartMin = currentTimeSlot.getMinutes()
    return (currentMinutes - currentTimeSlotStartMin) * 60
  }

  convertScheduleTime(scheduleTimeString) {
    const timeFormatted = scheduleTimeString.replace('am', ' am').replace('pm', ' pm')
    return new Date(`01/01/2011 ${timeFormatted}`)
  }

  attachIframe(videoID, start) {
    this.player = new YT.Player('player', {
      height: '390',
      width: '640',
      videoId: videoID,
      events: {
        'onStateChange': this.onPlayerStateChange,
        'onError': this.onPlayerError,
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

  onPlayerError(_event) {
    window.player.playInterstitialVideo()
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

    const contextContainer = document.getElementById('context__container')
    contextContainer.addEventListener('click', (event) => {
      const newChannelNumber = window.prompt('Enter New Channel Number', 25)
      this.saveChannelNumber(newChannelNumber)
    })
  }

  loadChannelNumber() {
    const number = this.getCookie('channelNumber')
    this.updateChannelNumber(number)
  }

  saveChannelNumber(number) {
    if (number && !isNaN(number)) {
      this.setCookie('channelNumber', number)
      this.updateChannelNumber(number)
    }
  }

  updateChannelNumber(number) {
    if (number && !isNaN(number)) {
      const channelNumber = document.getElementById('context__channel-number')
      channelNumber.innerHTML = number
    }
  }

  setCookie(key, value) {
    document.cookie = `${key}=${value};path=/`
  }

  getCookie(key) {
    return document.cookie.split('; ').reduce((r, v) => {
      const parts = v.split('=')
      return parts[0] === key ? decodeURIComponent(parts[1]) : r
    }, '')
  }

  reportContent() {
    const { time, show, episode, videoID } = this.currentShow()
    const issuePath = `https://github.com/imRohan/YTV-Schedule-Archives/issues/new?title=[${this.scheduleDate}] ${show}&body=${this.scheduleDate} @ ${time}: ${show}, ${episode}, incorrect video id: ${videoID}.&labels=Incorrect Content&assignees=imRohan`
    window.open(issuePath, '_blank').focus()
  }
}

window.PlayerComponent = PlayerComponent
