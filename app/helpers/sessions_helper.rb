module SessionsHelper
  def sign_in(user)
    # Make sure user in memory matches the one in the DB
    # by reloading it.
    user.reload
    session[:remember_token] = user.remember_token
    # expire in four hours
    session[:expires_at] = Time.zone.now + 4.hours
    self.current_user = user
  end

  def signed_in?
    !current_user.nil?
  end

  def current_user=(user)
    @current_user = user
  end

  def current_user
    # if the user is carrying an expired session, just return nil and force them to sign in again
    if session[:expires_at] && session[:expires_at] > Time.zone.now
      @current_user ||= User.find_by_remember_token(session[:remember_token])
    end
  end

  def sign_out
    self.current_user = nil
    session.delete(:remember_token)
  end

  def shib_logout_url
    redirect_url = Rails.application.config.shib_return_url
  end
end
