import { Controller } from "@hotwired/stimulus"

// Photo picker for items. Saved photos are server-rendered tiles carrying a hidden
// signed_id input; new files live in the file input. Removing a tile drops it on save.
export default class extends Controller {
  static targets = ["input", "list", "template", "tile", "dropzone", "counter", "error"]
  static values = { maxFiles: Number, maxSize: Number, types: Array }

  connect() {
    this.files = new DataTransfer()
    this.refresh()
  }

  select() {
    this.add(this.inputTarget.files)
  }

  dragOver(event) {
    event.preventDefault()
    this.dropzoneTarget.toggleAttribute("data-dragging", true)
  }

  dragLeave() {
    this.dropzoneTarget.removeAttribute("data-dragging")
  }

  drop(event) {
    event.preventDefault()
    this.dragLeave()
    this.add(event.dataTransfer.files)
  }

  remove(event) {
    const tile = event.currentTarget.closest("[data-image-preview-target~='tile']")

    if (tile.file) {
      const kept = new DataTransfer()
      Array.from(this.files.files).filter((file) => file !== tile.file).forEach((file) => kept.items.add(file))
      this.files = kept
      this.inputTarget.files = this.files.files
      URL.revokeObjectURL(tile.querySelector("img").src)
    }

    tile.remove()
    this.showError("")
    this.refresh()
  }

  add(fileList) {
    let rejected = 0

    for (const file of fileList) {
      const fits = this.tileTargets.length < this.maxFilesValue
      const valid = this.typesValue.includes(file.type) && file.size <= this.maxSizeValue

      if (!fits || !valid) {
        rejected++
        continue
      }

      this.files.items.add(file)
      this.listTarget.append(this.buildTile(file))
    }

    this.inputTarget.files = this.files.files
    this.showError(rejected ? `${rejected} foto(s) no se agregaron: máximo ${this.maxFilesValue}, JPG, PNG o WebP de hasta 10 MB.` : "")
    this.refresh()
  }

  buildTile(file) {
    const tile = this.templateTarget.content.firstElementChild.cloneNode(true)
    tile.file = file
    tile.querySelector("img").src = URL.createObjectURL(file)
    tile.querySelector("img").alt = file.name
    return tile
  }

  refresh() {
    const count = this.tileTargets.length

    this.tileTargets.forEach((tile, index) => {
      tile.querySelector("[data-principal]").classList.toggle("hidden", index !== 0)
    })
    this.counterTarget.textContent = `${count} / ${this.maxFilesValue}`
    this.dropzoneTarget.classList.toggle("hidden", count >= this.maxFilesValue)
    this.dropzoneTarget.classList.toggle("flex", count < this.maxFilesValue)
  }

  showError(message) {
    this.errorTarget.textContent = message
    this.errorTarget.classList.toggle("hidden", !message)
  }
}
