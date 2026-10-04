import { Controller } from "@hotwired/stimulus"

// Swaps a "view" pane for an "edit" pane. Fields in the hidden pane are disabled so they're never submitted.
export default class extends Controller {
  static targets = ["view", "edit"]

  edit() {
    this.trigger = document.activeElement
    this.toggle(true)
    this.editTarget.querySelector("input:not([type=hidden])")?.focus()
  }

  cancel() {
    this.editTarget.querySelectorAll("input:not([type=hidden])").forEach((input) => (input.value = input.defaultValue))
    this.toggle(false)
    if (this.trigger?.isConnected) this.trigger.focus()
  }

  toggle(editing) {
    this.viewTarget.hidden = editing
    this.editTarget.hidden = !editing
    this.fields(this.viewTarget).forEach((field) => (field.disabled = editing))
    this.fields(this.editTarget).forEach((field) => (field.disabled = !editing))
  }

  fields(pane) {
    return pane.querySelectorAll("input:not([type=hidden]), select, textarea")
  }
}
