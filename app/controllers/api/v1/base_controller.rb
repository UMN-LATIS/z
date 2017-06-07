class Api::V1::BaseController < ActionController::Base
  protect_from_forgery with: :null_session

  before_action :destroy_session, :api_authenticate

  def api_authenticate
    # Parse Auth Header
    user_uid, token = request.headers['Authorization'].split(':')
    head(:unauthorized) unless user_uid && token

    # Load User
    @current_user = User.find_by(uid: user_uid)
    head(:unauthorized) if @current_user.try(:sercet_key).blank?

    # Decode Token
    begin
      @payload = JWT.decode(token, @current_user.try(:secret_key), true, algorithm: 'HS256').first
    rescue JWT::VerificationError, JWT::ExpiredSignature
      head(:unauthorized)
    end
  end

  def destroy_session
    request.session_options[:skip] = true
  end

end
