class PasswordsController < ApplicationController
  layout "authentication_layout"
  allow_unauthenticated_access
  before_action :set_user_by_token, only: %i[ edit update ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_password_path, alert: "Intente de nuevo más tarde." }

  def new
  end

  def create
    if user = User.find_by(email_address: params[:email_address])
      PasswordsMailer.reset(user).deliver_later
    end

    redirect_to new_session_path, notice: "Si existe una cuenta con ese correo, te enviamos las instrucciones para restablecer tu contraseña."
  end

  def edit
  end

  def update
    if @user.update(params.permit(:password, :password_confirmation))
      @user.sessions.destroy_all
      redirect_to new_session_path, notice: "Tu contraseña se actualizó. Ya puedes iniciar sesión."
    elsif @user.errors.include?(:password_confirmation)
      redirect_to edit_password_path(params[:token]), alert: "Las contraseñas no coinciden."
    else
      redirect_to edit_password_path(params[:token]), alert: "La contraseña debe tener al menos 8 caracteres, una mayúscula, una minúscula y un número."
    end
  end

  private
    def set_user_by_token
      @user = User.find_by_password_reset_token!(params[:token])
    rescue ActiveSupport::MessageVerifier::InvalidSignature
      redirect_to new_password_path, alert: "El enlace para restablecer tu contraseña no es válido o ya expiró."
    end
end
