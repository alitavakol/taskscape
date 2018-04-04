class ApplicationController < ActionController::Base
  include Pundit
  after_action :verify_authorized, unless: :devise_controller?

  before_action :authenticate_user!

  protect_from_forgery with: :exception
  before_action :configure_permitted_parameters, if: :devise_controller?

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  protected

  def user_not_authorized
    respond_to do |format|
      format.html { redirect_to((request.referrer || root_path), alert: 'You are not authorized to perform this action.') }
      format.json { render json: {error: 'You are not authorized to perform this action.'}, status: :unauthorized }
    end
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
    devise_parameter_sanitizer.permit(:account_update, keys: ENV['I_AM_HEROKU'] ? [:name] : [:name, :avatar]) # heroku does not support file storage
  end

end
