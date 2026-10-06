# frozen_string_literal: true

# @param text [String] The button text content (can be nil for icon-only buttons)
# @param variant [Symbol] Button variant: :primary, :secondary, :outline, :ghost, :destructive
# @param size [Symbol] Size: :xs, :sm, :md (default), :lg
# @param style [Symbol] Visual style: :basic (default), :fancy (with enhanced shadows)
# @param pill [Boolean] Whether to use pill shape (rounded-full) instead of rounded corners
# @param disabled [Boolean] Whether the button is disabled
# @param loading [Boolean] Whether to show loading spinner
# @param icon [String] Optional icon SVG HTML (placed before text by default)
# @param icon_position [Symbol] Icon position: :left (default), :right
# @param icon_only [Boolean] Whether this is an icon-only button (no text)
# @param full_width [Boolean] Whether button should take full width
# @param href [String] If provided, renders as an anchor tag instead of button
# @param type [String] Button type attribute: "button" (default), "submit", "reset"
# @param classes [String] Additional CSS classes for the wrapper
# @param data [Hash] Data attributes for the button

module Button
  class Component < ViewComponent::Base
    VARIANTS = %i[primary secondary outline ghost destructive accent link].freeze
    SIZES = %i[xs sm md lg].freeze

    # Strings completos y literales para que Tailwind los detecte
    BASE = "cursor-pointer inline-flex items-center justify-center gap-2 font-medium whitespace-nowrap " \
           "transition-all duration-200 select-none active:scale-95 touch-manipulation " \
           "focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-ring " \
           "disabled:cursor-not-allowed disabled:opacity-50"

    VARIANT_CLASSES = {
      primary:     "bg-primary text-primary-foreground shadow-sm hover:bg-primary/90",
      secondary:   "bg-secondary text-secondary-foreground hover:bg-secondary/90",
      outline:     "border border-input bg-transparent text-foreground hover:bg-primary/10 hover:text-primary",
      ghost:       "bg-transparent text-foreground hover:bg-primary/10 hover:text-primary",
      destructive: "bg-destructive text-destructive-foreground hover:bg-destructive/90",
      accent:      "border border-border bg-accent text-accent-foreground hover:bg-primary/10 ",
      link:        "text-primary underline underline-offset-4 hover:text-primary/80"
    }.freeze

    SIZE_CLASSES = {
      xs: "px-3 py-2 text-xs",
      sm: "px-4 py-2.5 md:px-3 md:py-2 text-xs",
      md: "px-5 py-2.5 md:px-3.5 md:py-2 text-sm",
      lg: "px-6 py-3 md:px-4 md:py-2.5 text-base"
    }.freeze

    ICON_ONLY_SIZE_CLASSES = {
      xs: "p-2 text-xs",
      sm: "p-2.5 md:p-2 text-xs",
      md: "p-3 md:p-2.5 text-xs",
      lg: "p-4 md:p-3 text-sm"
    }.freeze

    ICON_CLASSES = {
      xs: "size-3",
      sm: "size-3 sm:size-3.5",
      md: "size-3.5 sm:size-4",
      lg: "size-4 sm:size-5"
    }.freeze

    attr_reader :text, :icon, :icon_position, :icon_only, :loading, :disabled

    def initialize(
      text: nil,
      variant: :primary,
      size: :md,
      pill: false,
      disabled: false,
      loading: false,
      icon: nil,
      icon_position: :left,
      icon_only: false,
      full_width: false,
      href: nil,
      type: "button",
      classes: nil,
      data: {},
      **options
    )
      super()
      @text = text
      @variant = VARIANTS.include?(variant) ? variant : :primary
      @size = SIZES.include?(size) ? size : :md
      @pill = pill
      @disabled = disabled || loading
      @loading = loading
      @icon = icon
      @icon_position = icon_position
      @icon_only = icon_only
      @full_width = full_width
      @href = href
      @type = type
      @classes = classes
      @data = data
      @options = options
    end

    def button_classes
      helpers.tw(
        BASE,
        (@icon_only ? ICON_ONLY_SIZE_CLASSES : SIZE_CLASSES)[@size],
        (@pill ? "rounded-full" : "rounded-lg"),
        VARIANT_CLASSES[@variant],
        (@full_width ? "w-full" : nil),
        @classes
      )
    end

    def tag_name
      @href.present? ? :a : :button
    end

    def tag_attributes
      attrs = { class: button_classes, data: @data }.merge(@options)

      if @href.present?
        attrs[:href] = @href
        attrs[:role] = "button"
        attrs[:"aria-disabled"] = @disabled if @disabled
      else
        attrs[:type] = @type
        attrs[:disabled] = @disabled if @disabled
      end

      attrs
    end

    def icon_classes
      ICON_CLASSES[@size]
    end

    def loading_spinner
      <<~SVG.html_safe
        <svg class="animate-spin #{icon_classes}" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
          <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
          <path class="opacity-75" fill="currentColor" d="m4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
        </svg>
      SVG
    end
  end
end
