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
    if auth_hash["extra"]["raw_info"]["https://www.umn.edu/shibboleth/attributes/isGuest"] == "Y"
      redirect_to root_path
      return
    end

    if auth_hash.extra.raw_info.attributes.key?("https://www.umn.edu/shibboleth/attributes/umnDID") && auth_hash.extra.raw_info.attributes["https://www.umn.edu/shibboleth/attributes/umnDID"].present?
      @user = User.find_or_create_by(
        uid: auth_hash[:extra][:raw_info][:"https://www.umn.edu/shibboleth/attributes/umnDID"]
      )
      sign_in @user
      redirect_to urls_path
    else
      render plain: 'Sorry, you are not authorized to use this application', status: :unauthorized
    end

  end

  def destroy
    sign_out
    redirect_to shib_logout_url, :allow_other_host => true
    
  end

  protected

  def auth_hash
    request.env['omniauth.auth']
  end
end
