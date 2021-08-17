# controllers/url_csvs_controller.rb
class Admin::UrlCsvsController < ApplicationController
  def show
    @duration = params[:duration]
    @time_unit = params[:time_unit]
    @urls = Url.all

    # Sneaky bad guy figures out url of target website and wants the good stuff
    # logs in only to find he is not in the group to which this url(s) belong?
    authorize @urls, :csvs? unless @urls.nil?

    respond_to do |format|
      format.csv { send_data Url.to_csv(@duration, @time_unit, @urls) }
    end
  end
end
