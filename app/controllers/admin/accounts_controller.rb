class Admin::AccountsController < Admin::BaseController
  # Copia aparte de Current.user: si la validación falla, la sesión no queda con datos sin guardar.
  before_action :set_user
  before_action :require_current_password, only: %i[ update destroy ]
  rate_limit to: 10, within: 3.minutes, only: %i[ update destroy ], with: -> { redirect_to edit_admin_account_path, alert: "Intente de nuevo más tarde." }

  def edit
  end

  def update
    if @user.update(account_params)
      # Cambiar la contraseña cierra las demás sesiones abiertas.
      @user.sessions.where.not(id: Current.session.id).destroy_all if @user.saved_change_to_password_digest?
      redirect_to edit_admin_account_path, notice: "Cambios guardados."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @user.destroy!
    cookies.delete(:session_id)
    redirect_to root_path, status: :see_other
  end

  private
    def set_user
      @user = User.find(Current.user.id)
    end

    def require_current_password
      return if @user.authenticate(params[:current_password].to_s)

      @user.errors.add(:base, "La contraseña actual es incorrecta")
      render :edit, status: :unprocessable_content
    end

    def account_params
      params.expect(user: [ :email_address, :password ])
    end
end
