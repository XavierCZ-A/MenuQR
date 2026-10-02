import { Controller } from "@hotwired/stimulus"

// Sticky category tabs: tapping a tab scrolls to its section,
// scrolling the page highlights the tab of the section in view.
export default class extends Controller {
  static targets = ["tab", "section", "bar"]

  connect() {
    this.lockedUntil = 0
    this.observer = new IntersectionObserver(
      (entries) => {
        // Ignore sections passed by while a tab tap is smooth-scrolling
        if (Date.now() < this.lockedUntil) return
        entries.filter((e) => e.isIntersecting).forEach((e) => this.activate(e.target.id))
      },
      { rootMargin: "-140px 0px -60% 0px" }
    )
    this.sectionTargets.forEach((section) => this.observer.observe(section))
  }

  disconnect() {
    this.observer.disconnect()
  }

  select(event) {
    event.preventDefault()
    const id = event.currentTarget.hash.slice(1)
    const smooth = !window.matchMedia("(prefers-reduced-motion: reduce)").matches

    this.lockedUntil = Date.now() + 800
    document.getElementById(id).scrollIntoView({ behavior: smooth ? "smooth" : "auto" })
    this.activate(id)
  }

  activate(id) {
    this.tabTargets.forEach((tab) => {
      const active = tab.hash === `#${id}`
      tab.toggleAttribute("data-active", active)
      if (active) {
        tab.setAttribute("aria-current", "true")
        this.barTarget.scrollTo({ left: tab.offsetLeft - 16, behavior: "smooth" })
      } else {
        tab.removeAttribute("aria-current")
      }
    })
  }
}
