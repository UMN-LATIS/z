class HomeController < ApplicationController
  before_action :redirect_to_urls_if_logged_in

  def index; end
end
