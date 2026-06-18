class PlayerComponent {
  constructor(schedule) {
    this.schedule = schedule
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
      return { show: "No Content", episode: "N/a", videoID: "123" }
    }
  }

  iframe() {
    const show = this.currentShow()
    return `
        <iframe width="560" height="315" src="https://www.youtube.com/embed/${show.videoID}?controls=0" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>`
  }

  loadPlayer() {
    this.attachIframe()
    this.loadNowPlayingData()
  }

  attachIframe() {
    const videoContainer = document.getElementById('video__container')
    videoContainer.innerHTML = this.iframe()
    console.log('iFrame loaded')
  }

  loadNowPlayingData() {
    const { show, episode } = this.currentShow()
    const titleContainer = document.getElementById('now-playing__title')
    const subTitleContainer = document.getElementById('now-playing__subtitle')
    const timeContainer = document.getElementById('time__container')
    titleContainer.innerHTML = show
    subTitleContainer.innerHTML = episode
    timeContainer.innerHTML = this.timeFormatted(this.currentTime())
    console.log('metadata loaded')
  }
}

window.PlayerComponent = PlayerComponent
