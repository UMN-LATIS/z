class Api::V1::BaseController < ActionController::Base
  protect_from_forgery with: :null_session

  before_action :destroy_session, :api_authenticate

  def api_authenticate
    auth_header = request.headers['Authorization']
    user_uid, token = auth_header.split(':')
    @current_user = User.find_by(uid: user_uid)
    begin
      @payload = JWT.decode(token, @current_user.try(:secret_key).to_s, true, algorithm: 'HS256').first
    rescue JWT::VerificationError
      head(:unauthorized)
    end
  end

  def destroy_session
    request.session_options[:skip] = true
  end
end
