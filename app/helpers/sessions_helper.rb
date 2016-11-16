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
    # if shib, then redirect_to shib logout

  end

  def shib_logout_url
     if request.env['Shib-Identity-Provider'].to_s.match(/login-test.umn.edu/)
       redirect_url='https://login-test.umn.edu/idp/profile/Logout'
     else
       redirect_url='https://login.umn.edu/idp/profile/Logout'
     end
     encoded_redirect_url = ERB::Util.url_encode(redirect_url)
     "https://#{request.host}/Shibboleth.sso/Logout?return=#{encoded_redirect_url}"
   end
end
