# frozen_string_literal: true

require "test_helper"

class BadgeComponentTest < ViewComponent::TestCase
  def test_renders_text_with_variant_classes
    render_inline(Badge::Component.new(text: "Nuevo", variant: :primary, title: "Etiqueta"))

    assert_selector "span.bg-primary[title=Etiqueta]", text: "Nuevo"
  end

  def test_unknown_variant_falls_back_to_outline
    render_inline(Badge::Component.new(text: "Picante", variant: :rainbow))

    assert_selector "span.border-border", text: "Picante"
  end
end
