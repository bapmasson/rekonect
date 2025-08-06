import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="level-up"
export default class extends Controller {
  connect() {
    if (window._levelUpListenerAdded) return;

    this._onLevelUp = this.show.bind(this)
    window.addEventListener("level-up", this._onLevelUp)
    window._levelUpListenerAdded = true
  }

  disconnect() {
    window.removeEventListener("level-up", this._onLevelUp)
    window._levelUpListenerAdded = false
  }

  show() {
    const box = document.createElement("div")
    box.classList.add("level-up-popup")
    box.innerHTML = "<h2>🎉 LEVEL UP !</h2>"
    document.body.appendChild(box)

    const audio = new Audio("/sounds/xp-gain.mp3")
    audio.play()

    setTimeout(() => box.remove(), 3000)
  }
}
