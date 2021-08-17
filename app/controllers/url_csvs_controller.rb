# controllers/url_csvs_controller.rb
class UrlCsvsController < ApplicationController
  def show_aggregated
    @duration = params[:duration]
    @time_unit = params[:time_unit]
    if params[:url_id].present?
      @urls = [Url.find(params[:url_id])]
    else
      @urls =
        Url.created_by_id(current_user.context_group_id).not_in_pending_transfer_request
    end

    # Sneaky bad guy figures out url of target website and wants the good stuff
    # logs in only to find he is not in the group to which this url(s) belong?
    authorize(@urls, :csvs?) unless @urls.nil?

    respond_to do |format|
      format.csv { send_data Url.to_csv(@duration, @time_unit, @urls) }
    end
  end

  def show
    url = Url.find(params[:url_id])
    authorize([url], :csvs?) unless @urls.nil?
    respond_to do |format|
      format.csv { send_data url.click_data_to_csv }
    end
  end
end
