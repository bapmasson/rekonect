import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = []
  connect() {
    console.log("Badge débloqué :", title, imageUrl);
  }

  show(event) {
    const { title, imageUrl } = event.detail
    const popup = document.createElement("div")
    popup.classList.add("badge-popup")
    popup.innerHTML = `
      <img src="${imageUrl}" alt="Badge" />
      <div class="badge-title">🏅 ${title}</div>
    `
    document.querySelector("#notifications-container").appendChild(popup)

    setTimeout(() => popup.remove(), 20000)
  }
}
