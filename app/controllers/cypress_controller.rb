class CypressController < ApplicationController
  skip_before_action :verify_authenticity_token

  def login
    if params[:email].present?
      user = User.find_by!(uid: params.require(:uid))
    else
      user = User.first!
    end
    sign_in(user)
    redirect_to URI.parse(params.require(:redirect_to)).path
  end
end
