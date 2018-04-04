class RegistrationsController < Devise::RegistrationsController
  protected

  # https://github.com/plataformatec/devise/wiki/How-To:-Redirect-to-a-specific-page-on-successful-sign-up-(registration)

  def after_inactive_sign_up_path_for(resource)
    new_user_session_url
  end

end
