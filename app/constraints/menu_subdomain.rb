# Public menus live at "<restaurant slug>.<APP_HOST>". Admin and auth stay on the bare APP_HOST.
class MenuSubdomain
  def self.matches?(request)
    slug_for(request).present?
  end

  def self.slug_for(request)
    slug = request.host.delete_suffix(".#{Rails.configuration.x.app_host}")
    slug if slug != request.host && !slug.include?(".") && Restaurant::RESERVED_SLUGS.exclude?(slug)
  end
end
