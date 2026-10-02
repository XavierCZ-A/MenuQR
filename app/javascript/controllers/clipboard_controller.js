import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["label"]
  static values = { text: String }

  async copy() {
    await navigator.clipboard.writeText(this.textValue)

    const original = this.labelTarget.textContent
    this.labelTarget.textContent = "¡Copiado!"
    setTimeout(() => (this.labelTarget.textContent = original), 2000)
  }
}
