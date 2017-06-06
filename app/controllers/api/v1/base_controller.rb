class Api::V1::BaseController < ActionController::Base
  protect_from_forgery with: :null_session

  before_action :sign_request
  before_action :destroy_session, :api_authenticate

  def api_authenticate
    @current_user = User.find_by(uid: ApiAuth.access_id(request))
    head(:unauthorized) unless @current_user && ApiAuth.authentic?(request, @current_user.secret_key)
  end

  def destroy_session
    request.session_options[:skip] = true
  end

  def sign_request
    # Test -- Simulate a client side signing with ApiAuth
    old_user = User.find_by(uid: '5scyi59j8')
    ApiAuth.sign!(request, old_user.uid, old_user.secret_key)
    # End Test
    # binding.pry
  end

end
