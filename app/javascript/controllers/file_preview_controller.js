import { Controller } from "@hotwired/stimulus"

// Vista previa de una sola imagen (logo, banner). "Quitar" la marca para borrarse al guardar.
export default class extends Controller {
  static targets = ["input", "image", "empty", "remove", "clear"]

  browse() {
    this.inputTarget.click()
  }

  preview() {
    const file = this.inputTarget.files[0]
    if (!file) return

    URL.revokeObjectURL(this.objectUrl)
    this.objectUrl = URL.createObjectURL(file)
    this.imageTarget.src = this.objectUrl
    this.removeTarget.value = "0"
    this.toggle(true)
  }

  clear() {
    this.inputTarget.value = ""
    this.removeTarget.value = "1"
    this.toggle(false)
  }

  disconnect() {
    URL.revokeObjectURL(this.objectUrl)
  }

  toggle(present) {
    this.imageTarget.hidden = !present
    this.emptyTarget.hidden = present
    this.clearTarget.hidden = !present
  }
}
