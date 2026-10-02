class UsersController < ApplicationController
  layout "authentication_layout"
  allow_unauthenticated_access only: %i[ new create ]

  def new
    @user = User.new
    @user.restaurants.build
  end

  def create
    @user = User.new(user_params)
    if @user.save
      start_new_session_for(@user)
      redirect_to admin_root_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(
      :email_address, :password,
      restaurants_attributes: [ :name ]
    )
  end
end
