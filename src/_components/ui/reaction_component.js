class ReactionComponent {
  constructor() {
    this.wssUrl = 'wss://socket.butterchickendinner.com'
    this.webSocket = null
    this.reactionsMap = {
      'f30838e1-8a19-4a25-b95f-625733edee35': '👀',
      '5de4cc03-fed0-478c-b19c-e1dc43a595c1': '🔥',
      'bb78f0f0-874e-4e91-a323-3617153b938c': '❤️',
    }
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
