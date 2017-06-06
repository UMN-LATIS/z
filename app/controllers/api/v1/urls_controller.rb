class Api::V1::UrlsController < Api::V1::BaseController
  def create
    # Find group_id to use for new URL
    if @payload['collection_name']
      @group_id = @current_user.groups.find_by(name: @payload['collection_name']).try(:id)
      if @group_id.blank?
        render json: { error: 'Cannot find collection with that name.' }
        return
      end
    else
      @group_id = @current_user.default_group_id
    end

    # Create URL
    @url = Url.new(url: @payload['url'], keyword: @payload['keyword'], group_id: @group_id)

    # Return
    if @url.save
      render json: { success: view_context.full_url(@url) }
    else
      render json: { error: @url.errors.full_messages }
    end
  end

end
