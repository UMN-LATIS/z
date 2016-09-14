# controllers/url_csvs_controller.rb
class UrlCsvsController < ApplicationController
  def show
    @duration = params[:duration]
    @time_unit = params[:time_unit]
    if params[:url_id].present?
      @urls = [Url.find(params[:url_id])]
    else
      @urls =
          Url.created_by_id(current_user.context_group_id).not_in_any_transfer_request
    end
    respond_to do |format|
      format.csv { send_data Url.to_csv(@duration, @time_unit, @urls) }
    end
  end

  private

  # Never trust parameters from the scary internet,
  # only allow the white list through.
  def url_csv_paramss
    params.require(:duration, :time_unit).permit(:url_id)
  end


end
