import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "input",
    "lengthCheck",
    "lowercaseCheck",
    "uppercaseCheck",
    "numberCheck",
  ];

  connect() {
    if (this.hasInputTarget) {
      this.checkRequirements();
    }
  }

  checkRequirements() {
    const password = this.inputTarget.value;

    this.updateRequirement(this.lengthCheckTarget, password.length >= 8);
    this.updateRequirement(this.lowercaseCheckTarget, /[a-z]/.test(password));
    this.updateRequirement(this.uppercaseCheckTarget, /[A-Z]/.test(password));
    this.updateRequirement(this.numberCheckTarget, /\d/.test(password));
  }

  updateRequirement(target, met) {
    if (!target) return;

    const icons = target.querySelectorAll("svg");
    const uncheckedIcon = icons[0];
    const checkedIcon = icons[1];
    const text = target.querySelector("span");

    if (met) {
      target.classList.remove("text-foreground/60");
      target.classList.add("text-primary");

      if (uncheckedIcon) uncheckedIcon.classList.add("hidden");
      if (checkedIcon) checkedIcon.classList.remove("hidden");

      if (text) text.classList.add("line-through");
    } else {
      target.classList.remove("text-primary");
      target.classList.add("text-foreground/60");

      if (uncheckedIcon) uncheckedIcon.classList.remove("hidden");
      if (checkedIcon) checkedIcon.classList.add("hidden");

      if (text) text.classList.remove("line-through");
    }
  }
}