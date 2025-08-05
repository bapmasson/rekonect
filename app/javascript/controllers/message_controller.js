import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="message"
export default class extends Controller {
  static values = { userId: Number }
  connect() {
     // triggered when a new message is added to the page
    const currentUserId = parseInt(document.body.dataset.currentUserId, 10);
    console.log(currentUserId);
    console.log(this.userIdValue);
    if (this.userIdValue === currentUserId) {
      this.element.classList.add('sms-me');
      this.element.classList.remove('sms-other');
    } else {
      this.element.classList.add('sms-other');
      this.element.classList.remove('sms-me');
    }
    this.element.scrollIntoView({ behavior: 'smooth' }); // scroll to the bottom of the page
  }
}
