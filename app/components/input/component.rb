# frozen_string_literal: true

module Input
  class Component < ViewComponent::Base
    SIZES = %i[sm md lg].freeze

    BASE = "block w-full rounded-lg border border-input bg-background " \
           "text-foreground placeholder:text-foreground/50 transition-colors " \
           "focus-visible:outline-2 focus-visible:outline-offset-2 " \
           "focus-visible:outline-ring disabled:cursor-not-allowed " \
           "disabled:opacity-50"

    SIZE_CLASSES = {
      sm: "h-9 px-3 py-1.5 text-xs",
      md: "h-10 px-3 py-2 text-sm",
      lg: "h-12 px-4 py-3 text-base"
    }.freeze

    attr_reader :label, :required

    def initialize(
      name:,
      type: :text,
      value: nil,
      label: nil,
      placeholder: nil,
      id: nil,
      size: :md,
      required: false,
      disabled: false,
      readonly: false,
      classes: nil,
      data: {},
      **options
    )
      super()

      @name = name
      @type = type
      @value = value
      @label = label
      @placeholder = placeholder
      @id = id
      @size = SIZES.include?(size) ? size : :md
      @required = required
      @disabled = disabled
      @readonly = readonly
      @classes = classes
      @data = data
      @options = options.symbolize_keys
    end

    def input_id
      @id.presence ||
        @name.to_s.delete("]").gsub(/[^a-zA-Z0-9:_-]/, "_")
    end

    def input_classes
      helpers.tw(
        BASE,
        SIZE_CLASSES[@size],
        @classes,
        @options[:class]
      )
    end

    def tag_attributes
      @options.merge(
        id: input_id,
        type: @type,
        name: @name,
        value: @value,
        placeholder: @placeholder,
        required: @required,
        disabled: @disabled,
        readonly: @readonly,
        class: input_classes,
        data: @data
      )
    end
  end
end
