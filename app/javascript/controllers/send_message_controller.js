import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="send-message"
export default class extends Controller {
  static targets = ["form"]

  submit(event) {
    event.preventDefault()

    const url = this.formTarget.action
    const formData = new FormData(this.formTarget)

    fetch(url, {
      method: "POST",
      headers: {
        "Accept": "application/json",
        "X-CSRF-Token": document.querySelector("[name='csrf-token']").content // sécurité rails
      },
      body: formData
    })
      .then(response => response.json())
      .then(data => {
        // reset le champ
        this.formTarget.reset()

        // met à jour les valeurs dynamiques de la barre d’XP
        const fill = document.querySelector(".xp-bar-fill")
        const progress = document.querySelector(".xp-bar-progress")
        const level = document.querySelector(".xp-level-number")

        if (fill) {
          fill.dataset.xpPercent = data.xp_percent
          fill.dataset.xpCurrent = data.xp_progress
          fill.dataset.xpTotal = data.xp_total
          // Animation
          requestAnimationFrame(() => {
            fill.style.width = `${data.xp_percent}%`
          })
        }

        if (progress) {
          progress.innerText = `${data.xp_progress}/${data.xp_total} XP`
        }

        if (level) {
          level.innerText = data.level
        }
        
        if (data.level_up) {
          window.dispatchEvent(new Event("level-up"))
        }
      })
      .catch(error => {
        console.error("Erreur envoi message", error)
      })
  }
}
