class SessionsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def new
    redirect_to "/auth/#{Rails.application.config.omniauth_provider}"
  end

  def create
    # Filter out isGuest shibboleth requests. This is almost surely the wrong way to filter logins with
    # omniAuth. TODO: refactor.
    if !Rails.env.development? && auth_hash['extra']['raw_info']['isGuest'] == 'Y'
      redirect_to root_path
      return
    end

    @user = User.find_or_create_by(
      uid: auth_hash[:uid]
    )

    sign_in @user
    redirect_to urls_path
  end

  def destroy
    sign_out
    if Rails.env.development?
      redirect_to root_path
    else
      redirect_to shib_logout_url
    end
  end

  protected

  def auth_hash
    request.env['omniauth.auth']
  end
end
