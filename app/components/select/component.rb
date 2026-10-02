# frozen_string_literal: true

module Select
  class Component < ViewComponent::Base
    SIZES = %i[sm md lg].freeze

    BASE = "block w-full rounded-lg border border-input bg-background " \
           "text-foreground transition-colors " \
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
      collection:,
      value_method: :id,
      text_method: :name,
      selected: nil,
      label: nil,
      prompt: nil,
      id: nil,
      size: :md,
      required: false,
      disabled: false,
      classes: nil,
      data: {},
      **options
    )
      super()

      @name = name
      @collection = collection
      @value_method = value_method
      @text_method = text_method
      @selected = selected
      @label = label
      @prompt = prompt
      @id = id
      @size = SIZES.include?(size) ? size : :md
      @required = required
      @disabled = disabled
      @classes = classes
      @data = data
      @options = options.symbolize_keys
    end

    def select_id
      @id.presence ||
        @name.to_s.delete("]").gsub(/[^a-zA-Z0-9:_-]/, "_")
    end

    def select_classes
      helpers.tw(
        BASE,
        SIZE_CLASSES[@size],
        @classes,
        @options[:class]
      )
    end

    def option_tags
      helpers.options_from_collection_for_select(
        @collection,
        @value_method,
        @text_method,
        @selected
      )
    end

    def tag_attributes
      @options.merge(
        id: select_id,
        required: @required,
        disabled: @disabled,
        class: select_classes,
        data: @data,
        prompt: @prompt
      )
    end
  end
end
