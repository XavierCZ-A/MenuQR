# Admin and auth live on any host that isn't a menu subdomain (APP_HOST, www, reserved slugs).
class MainDomain
  def self.matches?(request)
    !MenuSubdomain.matches?(request)
  end
end
