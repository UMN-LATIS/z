class Api::V1::UrlsController < Api::V1::BaseController
  def create
    # Create URL
    @url = Url.new(url: params[:url], group_id: @current_user.default_group_id)

    # Return
    if @url.save
      render json: view_context.full_url(@url).to_json
    else
      render json: { errors: @url.errors.full_messages }
    end
  end

end
