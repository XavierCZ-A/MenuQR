module ApplicationHelper
  def render_svg(name, styles: "w-6 h-6")
    file_path = Rails.root.join("app/assets/images", name)
    return unless File.exist?(file_path)

    file = File.read(file_path)
    doc = Nokogiri::HTML::DocumentFragment.parse(file)
    svg = doc.at_css("svg")
    svg["class"] = styles
    doc.to_html.html_safe
  end

  def tw(*classes)
    TailwindMerge::Merger.new.merge(classes.compact.join(" "))
  end
end
