class LandingController < ApplicationController
  allow_unauthenticated_access

  def show
    redirect_to admin_root_path if authenticated?
  end
end
