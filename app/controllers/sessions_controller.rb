class SessionsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def new
    redirect_to "/auth/#{Rails.application.config.omniauth_provider}"
  end

  def create
    @user = User.find_or_create_by(
      uid:      auth_hash[:uid]
    )

    sign_in @user
    redirect_to urls_path
  end

  def destroy
    sign_out
    redirect_to shib_logout_url
  end

  protected

  def auth_hash
    request.env['omniauth.auth']
  end

end
