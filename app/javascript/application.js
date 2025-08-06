// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import "@popperjs/core"
import "bootstrap"


window.addEventListener("level-up", () => {
  document.querySelector("[data-controller~='level-up']")?.dispatchEvent(new CustomEvent("show"));
});

window.addEventListener("badge-unlocked", (e) => {
  const { title, imageUrl } = e.detail;
  document.querySelector("[data-controller~='badge-popup']")?.dispatchEvent(
    new CustomEvent("show", { detail: { title, imageUrl } })
  );
});
