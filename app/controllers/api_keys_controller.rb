class ApiKeysController < ApplicationController
  before_action :ensure_signed_in
  def index; end

  def create
    current_user.secret_key = ApiAuth.generate_secret_key
    if current_user.save
      sign_in current_user
    else
      flash[:error] = 'There was an error creating your secret-key. Please try again.'
    end
    redirect_to :api_keys
  end

  def destroy
    current_user.secret_key = nil
    if current_user.save
      sign_in current_user
    else
      flash[:error] = 'There was an error deleting your secret-key. Please try again.'
    end
    redirect_to :api_keys
  end
end
