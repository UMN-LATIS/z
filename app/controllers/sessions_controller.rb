def is_dev_or_test_env?
  Rails.env.local?
end

class SessionsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def new
    @auth_provider = Rails.application.config.omniauth_provider
  end

  def create
    # Filter out isGuest shibboleth requests. This is almost surely the wrong way to filter logins with
    # omniAuth. TODO: refactor.
    if !is_dev_or_test_env? && auth_hash["extra"]["raw_info"]["isGuest"] == "Y"
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
    if is_dev_or_test_env?
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
