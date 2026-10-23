class SettingsComponent {
  constructor() {
    this.animations = true
    this.ui = true
  }

  init() {
    this.initClickEvents()
  }

  initClickEvents() {
    const animations = document.getElementById('settings-animations')
    animations.addEventListener('click', () => {
      this.toggleAnimations()
    })

    const ui = document.getElementById('settings-ui')
    ui.addEventListener('click', () => {
      this.toggleUI()
    })
  }

  toggleAnimations() {
    this.animations = !this.crtEnabled
    document.body.classList.toggle('animations--disabled')
  }

  toggleUI() {
    this.ui = !this.ui
    document.body.classList.toggle('ui--disabled')
  }
}

window.SettingsComponent = SettingsComponent
