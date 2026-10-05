# frozen_string_literal: true

module CategoryRow
  class Component < ViewComponent::Base
    with_collection_parameter :category

    delegate :render_svg, to: :helpers

    # category:        la categoría de la fila
    # failed_category: la categoría que falló al guardarse (si hubo una);
    #                  solo se usa si corresponde a esta fila
    # only_category:   true si es la única categoría del menú
    def initialize(category:, failed_category: nil, only_category: false)
      @category = category
      @failed_category = failed_category if failed_category&.id == category.id
      @only_category = only_category
    end

    private

    attr_reader :category

    def editing?
      @failed_category.present?
    end

    def form_record
      @failed_category || category
    end

    def without_items?
      category.items_count.zero?
    end

    def deletable?
      without_items? && !@only_category
    end

    def items_label
      return "Sin platillos · no aparece en el menú" if without_items?

      pluralize(category.items_count, "platillo", "platillos")
    end

    def delete_title
      return "Eliminar" if deletable?
      return "Tu menú necesita al menos una categoría" if without_items?

      "Mueve o borra sus platillos primero"
    end

    def error_message
      @failed_category.errors.full_messages.to_sentence
    end
  end
end
