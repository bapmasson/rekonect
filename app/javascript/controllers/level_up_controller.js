import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="level-up"
export default class extends Controller {
  connect() {
    if (window._levelUpListenerAdded) return;

    this._onLevelUp = this.show.bind(this)
    window.addEventListener("level-up", this._onLevelUp)
    window._levelUpListenerAdded = true

    // affiche au refresh si on a déjà un lvl up en attente
    const pendingLevelUp = document.getElementById("pending-levelup")
    if (pendingLevelUp) {
      const level = pendingLevelUp.dataset.level
      if (window.lastLevelUp !== level) {
        window.lastLevelUp = level
        this.show({ detail: { level } }) // asse le niveau directement
      }
    }
  }

  disconnect() {
    window.removeEventListener("level-up", this._onLevelUp)
    window._levelUpListenerAdded = false
  }

  show(event) {
  // supprime d'abord modale fantome
    document.querySelectorAll('.level-up-popup').forEach(e => e.remove());
    // condition pour recuperer l'event ou nul si absent
    let level = event && event.detail && event.detail.level ? event.detail.level : null;
    // injecte le html
    const box = document.createElement("div");
    box.classList.add("level-up-popup");
    box.innerHTML = `
      <h2 class="level-up-title">
        🎉 LEVEL UP !
        ${level ? `<span class="level-badge">LVL ${level}</span>` : ""}
      </h2>
      <p class="level-up-message">Bravo pour ta progression 🌱</p>
      <div class="confettis"></div>
    `;
    document.body.appendChild(box);

    // Son
    const audio = new Audio("/sounds/xp-gain.mp3");
    audio.play();

    setTimeout(() => box.remove(), 3500);
  }
}
