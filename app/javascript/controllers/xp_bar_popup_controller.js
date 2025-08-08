import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="xp-bar-popup"
export default class extends Controller {
  connect() {
    window.addEventListener("xp-gain", this.show.bind(this))
  }

  disconnect() {
    window.removeEventListener("xp-gain", this.show.bind(this))
  }

  show(event) {
    // efface la modale fantome xp gain avant d'en rajouter une
    document.querySelectorAll('.xp-bar-popup-container').forEach(el => el.remove());

    const template = document.getElementById("xp-bar-popup-template")
    if (!template) return

    const clone = template.content.cloneNode(true)
    const popup = document.createElement("div")
    popup.classList.add("xp-bar-popup-container")
    popup.appendChild(clone)

    // event dy namique
    if (event && event.detail) {
      const { xpPercent, xpCurrent, xpTotal, level } = event.detail
      const fill = popup.querySelector('.xp-bar-fill')
      if (fill) {
        fill.dataset.xpPercent = xpPercent
        fill.dataset.xpCurrent = xpCurrent
        fill.dataset.xpTotal = xpTotal
        setTimeout(() => {
          fill.style.width = `${xpPercent}%`
        }, 30)
      }
      const progress = popup.querySelector('.xp-bar-progress')
      if (progress) progress.textContent = `${xpCurrent}/${xpTotal} XP`
      const levelText = popup.querySelector('.xp-level-number')
      if (levelText) levelText.textContent = `LVL ${level}`
    }
     // remove auto
    document.body.appendChild(popup)
    setTimeout(() => popup.remove(), 3000)
  }
}
