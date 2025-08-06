import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="xp-bar"
export default class extends Controller {
  static targets = ["fill", "progress", "level"]

  connect() {
    console.log("XP Bar controller connecté")
  }

  update(event) {
    const { xp, level } = event.detail

    const percent = xp % 100
    const xpInLevel = xp % 100

    if (this.fillTarget) {
      this.fillTarget.style.width = `${percent}%`
    }

    if (this.progressTarget) {
      this.progressTarget.innerText = `${xpInLevel}/100 XP`
    }

    if (this.levelTarget) {
      this.levelTarget.innerText = `${Math.floor(xp / 100) + 1}`
    }
  }
}
