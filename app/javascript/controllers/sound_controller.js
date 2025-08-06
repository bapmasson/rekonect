import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="sound"
export default class extends Controller {
  play(soundPath) {
    const audio = new Audio(soundPath)
    audio.play()
  }
}
