# frozen_string_literal: true

module Badge
  class Component < ViewComponent::Base
    # Strings completos y literales para que Tailwind los detecte
    BASE = "inline-flex shrink-0 items-center gap-1 rounded-full font-medium whitespace-nowrap"

    VARIANTS = {
      primary: "bg-primary text-primary-foreground",
      outline: "border border-border bg-card text-foreground",
      muted:   "bg-foreground/5 text-foreground/70"
    }.freeze

    SIZES = {
      sm: "px-2 py-0.5 text-[0.6875rem]",
      md: "px-2.5 py-0.5 text-xs"
    }.freeze

    def initialize(text:, variant: :outline, size: :md, classes: nil, **options)
      super()

      @text = text
      @variant = VARIANTS.key?(variant) ? variant : :outline
      @size = SIZES.key?(size) ? size : :md
      @classes = classes
      @options = options
    end

    def badge_classes
      helpers.tw(BASE, VARIANTS[@variant], SIZES[@size], @classes)
    end
  end
end
