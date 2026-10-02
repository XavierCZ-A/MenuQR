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

  def nav_link(text, path)
    active = current_page?(path) ? "bg-gray-100 px-6 py-1.5 rounded-lg text-primary font-medium" : " px-6 py-1.5 rounded-lg text-primary font-medium hover:bg-gray-100"
    link_to text, path, class: " #{active}"
  end
end
