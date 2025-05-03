def is_dev_or_test_env?
  Rails.env.local?
end

class SessionsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def new
    @auth_provider = Rails.application.config.omniauth_provider
  end

  def create
    # short circuit and just sign in if we're using the developer provider
    if Rails.application.config.omniauth_provider == "developer"
      @user = User.find_or_create_by(
        uid: auth_hash[:uid],
      )
      sign_in @user
      redirect_to urls_path
      return
    end

    # if we're a guest, redirect to the root path
    if auth_hash["extra"]["raw_info"][ENV['SHIB_IS_GUEST']] == "Y"
      redirect_to root_path
      return
    end

    # if there's a valid uid sign in
    if auth_hash.extra.raw_info.attributes.key?() && auth_hash.extra.raw_info.attributes[ENV["SHIB_DID"]].present?
      @user = User.find_or_create_by(
        uid: auth_hash[:extra][:raw_info][ENV["SHIB_DID"]],
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
