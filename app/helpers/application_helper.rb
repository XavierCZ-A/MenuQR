module ApplicationHelper
  TW_MERGER = TailwindMerge::Merger.new
  SVG_CACHE = Concurrent::Map.new

  def render_svg(name, styles: "w-6 h-6")
    # En desarrollo no cacheamos, para ver los cambios al editar un SVG
    return build_svg(name, styles) if Rails.env.development?

    SVG_CACHE.compute_if_absent([ name, styles ]) { build_svg(name, styles) }
  end

  def tw(*classes)
    TW_MERGER.merge(classes.compact.join(" "))
  end

  private

  def build_svg(name, styles)
    file_path = Rails.root.join("app/assets/images", name)
    return unless File.exist?(file_path)

    doc = Nokogiri::HTML::DocumentFragment.parse(File.read(file_path))
    svg = doc.at_css("svg")
    return unless svg

    svg["class"] = styles
    doc.to_html.html_safe.freeze
  end
end

# def render_svg(name, styles: "w-6 h-6")
#   file_path = Rails.root.join("app/assets/images", name)
#   return unless File.exist?(file_path)

#   file = File.read(file_path)
#   doc = Nokogiri::HTML::DocumentFragment.parse(file)
#   svg = doc.at_css("svg")
#   svg["class"] = styles
#   doc.to_html.html_safe
# end
