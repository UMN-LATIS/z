# controllers/url_csvs_controller.rb
class Admin::UrlCsvsController < ApplicationController
  def show
    if current_user.admin?
      @duration = params[:duration]
      @time_unit = params[:time_unit]
      @urls = Url.all
      respond_to do |format|
        format.csv { send_data Url.to_csv(@duration, @time_unit, @urls) }
      end
    else
      # user not authorized
      redirect_to root_url
    end
  end
end
