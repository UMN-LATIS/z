# controllers/url_csvs_controller.rb
class UrlCsvsController < ApplicationController
  def show
      @stat_id = params[:stat_id]
      @url = Url.find(params[:url_id])
      respond_to do |format|
        format.csv {send_data Url.to_csv(@stat_id, [@url])}
      end
  end

  def show_all
    @stat_id = params[:stat_id]
    # admin will need to switch to own context to see csv of their own urls only
    if current_user.admin
      @urls = Url.all
    else
      @urls =
          Url.created_by_id(current_user.context_group_id).not_in_any_transfer_request
    end
    respond_to do |format|
      format.csv {send_data Url.to_csv(@stat_id, @urls)}
    end
  end
end
