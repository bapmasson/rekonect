import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="xp-bar"
export default class extends Controller {
  static targets = ["fill", "progress", "level"]

  connect() {
    const fill = this.fillTarget

    const percent = parseFloat(fill.dataset.xpPercent || 0)
    const current = parseInt(fill.dataset.xpCurrent || 0)
    const total = parseInt(fill.dataset.xpTotal || 100)

    // Démarre à 0%
    fill.style.width = "0%"

    // Déclenche l'animation au prochain frame
    requestAnimationFrame(() => {
      fill.style.width = `${percent}%`
    })

    if (this.progressTarget) {
      this.progressTarget.innerText = `${current}/${total} XP`
    }

    /* if (this.levelTarget) {
      const level = Math.floor(current / total) + 1
      this.levelTarget.innerText = level
    } */
  }
}
