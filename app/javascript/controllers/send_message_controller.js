import { Controller } from "@hotwired/stimulus"

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
        "X-CSRF-Token": document.querySelector("[name='csrf-token']").content
      },
      body: formData
    })
      .then(response => response.json())
      .then(data => {
  // Envoie un event personnalisé pour mettre à jour la barre d’XP
  window.dispatchEvent(new CustomEvent("xp-gained", {
    detail: { xp: data.xp_gained, level: data.level }
  }))

  // Si le backend t’envoie une info de level-up
  if (data.level_up === true) {
    window.dispatchEvent(new CustomEvent("level-up"))
  }

  // Insère le nouveau message dans le DOM
  const messagesContainer = document.getElementById("messages")
  messagesContainer.insertAdjacentHTML("beforeend", data.html)

  // Réinitialise le formulaire
  this.formTarget.reset()
  } )
} }
