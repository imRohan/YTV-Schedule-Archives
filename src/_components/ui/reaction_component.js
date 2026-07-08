class ReactionComponent {
  constructor(reactionsMap) {
    this.wssUrl = 'wss://socket.butterchickendinner.com'
    this.webSocket = null
    this.reactionsMap = reactionsMap
    this.connectedReaction = Object.keys(this.reactionsMap).shift()
    this.container = document.getElementById('reaction__container')
  }

  connect() {
    this.webSocket = new WebSocket(this.wssUrl)
    this.webSocket.onopen = () => {
      this.attachHandlers()
      this.enableUI()
      this.publishConnectedMessage()
    }
  }

  attachHandlers() {
    this.webSocket.onmessage = (event) => {
      const { data } = event
      this.handleMessage(data)
    }
  }

  handleMessage(message) {
    if (this.reactionsMap[message]) {
      this.displayReaction(message)
    }
  }

  enableUI() {
    Object.keys(this.reactionsMap).slice(1).forEach((id) => {
      const element = document.createElement('button')
      element.classList.add('reaction__button')
      element.innerHTML = this.reactionsMap[id]
      element.dataset.id = id
      this.container.appendChild(element)
      element.addEventListener('click', this.handleReactionClicked)
    })
    this.container.classList.add('reactions--connected')
  }

  publishConnectedMessage() {
    this.publishReaction(this.connectedReaction)
  }

  handleReactionClicked(element) {
    const reactionElement = element.target
    const { id }  = reactionElement.dataset
    window.reactionComponent.publishReaction(id)
    window.reactionComponent.displayReaction(id)
  }

  publishReaction(id) {
    this.webSocket.send(id)
  }

  displayReaction(id) {
    const icon = this.reactionsMap[id]
    const element = document.createElement('reaction')
    element.classList.add('reaction', 'reaction--visible')
    element.innerHTML = icon
    document.body.appendChild(element)
    setTimeout(() => {
      element.remove()
    }, 2000)
  }
}

window.ReactionComponent = ReactionComponent
