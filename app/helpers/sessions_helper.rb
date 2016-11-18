module SessionsHelper
  def sign_in(user)
    # Make sure user in memory matches the one in the DB
    # by reloading it.
    user.reload
    cookies.permanent[:remember_token] = user.remember_token
    self.current_user = user
  end

  def signed_in?
    !current_user.nil?
  end

  def current_user=(user)
    @current_user = user
  end

  def current_user
    @current_user ||= User.find_by_remember_token(cookies[:remember_token])
  end

  def sign_out
    self.current_user = nil
    cookies.delete(:remember_token)
  end

  def shib_logout_url
    redirect_url = Rails.application.config.shib_return_url 
    encoded_redirect_url = ERB::Util.url_encode(redirect_url)
    "http://#{request.host}/Shibboleth.sso/Logout?return=#{encoded_redirect_url}"
  end
end
