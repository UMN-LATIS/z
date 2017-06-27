class Api::V1::BaseController < ActionController::Base
  protect_from_forgery with: :null_session

  before_action :destroy_session, :api_authenticate

  def api_authenticate
    # Verify Auth Header
    # head(:unauthorized) && return unless request.headers['Authorization']

    # Parse Auth Header
    user_uid, token = request.headers['Authorization'].split(':')
    head(:unauthorized) && return unless user_uid && token

    # Load User
    @current_user = User.find_by(uid: user_uid)
    head(:unauthorized) && return unless @current_user && @current_user.secret_key

    # Decode Token
    begin
      @payload = JWT.decode(token, @current_user.secret_key, true, algorithm: 'HS256').first
    rescue JWT::VerificationError, JWT::ExpiredSignature
      head(:unauthorized)
    end
  end

  def destroy_session
    request.session_options[:skip] = true
  end
end
