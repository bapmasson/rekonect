import { Controller } from "@hotwired/stimulus"

// Définition du contrôleur Stimulus pour gérer l'affichage d'une infobulle (tooltip) - utilisé pour les badges dans la barre d'XP
export default class extends Controller {

  static values = { title: String, description: String, condition: String }

  connect() {
    // Ajoute un event listener pour afficher l'infobulle au survol
    this.element.addEventListener("mouseenter", () => this.showTooltip())
    // Ajoute un event listener pour masquer l'infobulle lorsque la souris quitte l'élément
    this.element.addEventListener("mouseleave", () => this.hideTooltip())
  }

  // Affiche l'infobulle
  showTooltip() {
    // Récupère les données à afficher dans l'infobulle depuis les data-attributes
    const title = this.titleValue
    const description = this.descriptionValue
    const condition = this.conditionValue

    // Crée l'élément div qui servira d'infobulle
    const tooltip = document.createElement("div")
    tooltip.className = "badge-tooltip"
    // Définit le contenu HTML de l'infobulle
    tooltip.innerHTML = `<strong>${title}</strong><br>${description}<br><em>${condition}</em>`
    // Ajoute l'infobulle au body du document
    document.body.appendChild(tooltip)

    // Calcule la position de l'infobulle par rapport à l'élément cible
    const rect = this.element.getBoundingClientRect()
    tooltip.style.top = `${rect.bottom + window.scrollY + 5}px`
    tooltip.style.left = `${rect.left + window.scrollX}px`
    // Stocke une référence à l'infobulle pour pouvoir la supprimer plus tard
    this.tooltip = tooltip
  }

  // Masque et supprime l'infobulle
  hideTooltip() {
    if (this.tooltip) {
      this.tooltip.remove()
      this.tooltip = null
    }
  }

}
