import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    window.addEventListener("xp-gained", (e) => {
      const { xp, level } = e.detail
      this.show(xp, level)
    })
  }

  show(xp, level) {
  const box = document.createElement("div")
  box.classList.add("xp-notice-popup")

  box.innerHTML = `
    <h2>✨ +${xp} XP</h2>
    <p>Tu as Rekonecté avec succès !<br>Niveau actuel : ${level}</p>
  `

  document.querySelector("#notifications-container")?.appendChild(box)

  const sound = new Audio("/sounds/xp-gain.mp3")
  sound.play()

  setTimeout(() => {
    box.remove()
  }, 3000)
 }
}
