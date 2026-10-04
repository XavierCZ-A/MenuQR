import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"

// Drag & drop (mouse/touch) plus arrow keys on the handle; saves the full order on every change.
export default class extends Controller {
  static targets = ["list", "preview", "status"]
  static values = { url: String }

  connect() {
    this.sortable = Sortable.create(this.listTarget, {
      handle: "[data-sortable-handle]",
      animation: 150,
      ghostClass: "opacity-40",
      chosenClass: "shadow-lg",
      onEnd: ({ oldIndex, newIndex }) => oldIndex !== newIndex && this.save(),
    })
  }

  disconnect() {
    this.sortable.destroy()
  }

  move(event) {
    const row = event.currentTarget.closest("li")
    const sibling = { ArrowUp: row.previousElementSibling, ArrowDown: row.nextElementSibling }[event.key]
    if (sibling === undefined) return

    event.preventDefault()
    if (!sibling) return

    event.key === "ArrowUp" ? sibling.before(row) : sibling.after(row)
    event.currentTarget.focus()
    this.save()
  }

  async save() {
    const ids = [...this.listTarget.children].map((row) => row.dataset.id)
    this.syncPreview(ids)
    this.statusTarget.textContent = "Guardando…"

    try {
      const response = await fetch(this.urlValue, {
        method: "PATCH",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": document.querySelector("meta[name=csrf-token]").content,
        },
        body: JSON.stringify({ category_ids: ids }),
      })
      if (!response.ok) throw new Error(response.status)
      this.statusTarget.textContent = "✓ Orden guardado"
    } catch {
      this.statusTarget.textContent = "No se pudo guardar. Recarga la página e intenta de nuevo."
    }
  }

  syncPreview(ids) {
    const pills = Object.fromEntries([...this.previewTarget.children].map((pill) => [pill.dataset.id, pill]))
    ids.forEach((id) => pills[id] && this.previewTarget.append(pills[id]))
  }
}
