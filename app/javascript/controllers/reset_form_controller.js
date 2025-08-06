import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="reset-form"
export default class extends Controller {
  connect() {
    this.element.scrollIntoView({ behavior: "smooth" });
  }
  reset() {
    // Reset le champ de saisie du formulaire
    this.element.reset()
    }
}
