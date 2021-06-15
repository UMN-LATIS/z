class HomeController < ApplicationController
  before_action :redirect_to_urls_if_logged_in
  force_ssl if: :ssl_configured?
  def index

  end
  
  def ssl_configured?
    !Rails.env.development?
  end

end
