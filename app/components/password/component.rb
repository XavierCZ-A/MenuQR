# frozen_string_literal: true

module Password
  class Component < ViewComponent::Base
    # @param label [String] The password field label text
    # @param name [String] The input name attribute for form submission
    # @param id [String] The input id attribute (auto-generated if not provided)
    # @param placeholder [String] Placeholder text for the input
    # @param value [String] The initial value (rarely used for security)
    # @param required [Boolean] Whether the input is required
    # @param disabled [Boolean] Whether the input is disabled
    # @param autocomplete [String] Autocomplete attribute value
    # @param error [String] Error message to display
    # @param hint [String] Hint text below the input
    # @param classes [String] Additional CSS classes for the wrapper
    # @param input_classes [String] Additional CSS classes for the input element

    def initialize(
      label: "Password",
      name: nil,
      id: nil,
      placeholder: nil,
      value: nil,
      required: false,
      disabled: false,
      autocomplete: "current-password",
      error: nil,
      hint: nil,
      classes: nil,
      input_classes: nil
    )
      super()
      @label = label
      @name = name
      @id = id || generate_id
      @placeholder = placeholder
      @value = value
      @required = required
      @disabled = disabled
      @autocomplete = autocomplete
      @error = error
      @hint = hint
      @classes = classes
      @input_classes = input_classes
    end

    def wrapper_classes
      base = "w-full"
      [ base, @classes ].compact.reject(&:empty?).join(" ")
    end

    def input_classes
      base = "flex h-10 w-full rounded-lg border border-input bg-background px-3 py-2 text-sm text-foreground placeholder:text-foreground/50 transition-colors focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-ring disabled:cursor-not-allowed disabled:opacity-50"
      error_class = @error.present? ? "error" : ""
      disabled_class = @disabled ? "opacity-50 cursor-not-allowed" : ""
      [ base, error_class, disabled_class, @input_classes ].compact.reject(&:empty?).join(" ")
    end

    def error_classes
      "text-xs text-red-600 mt-1"
    end

    def hint_classes
      "text-xs text-neutral-500 mt-1"
    end

    private

    def generate_id
      "password_#{SecureRandom.hex(4)}"
    end

    attr_reader :label, :name, :id, :placeholder, :value, :required, :disabled,
                :autocomplete, :error, :hint
  end
end
