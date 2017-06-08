class Api::V1::UrlsController < Api::V1::BaseController
  def create
    urls = @payload['urls']

    urls.each do |url|
      # Find group_id to use for new URL
      if url['collection_name']
        group_id = @current_user.groups.find_by(name: url['collection_name']).try(:id)
        if group_id.blank?
          url['result'] = { status: :error, message: 'Cannot find collection with that name.' }
          next
        end
      else
        group_id = @current_user.default_group_id
      end

      new_url = Url.new(url: url['url'], keyword: url['keyword'], group_id: group_id)

      url['result'] =
        if new_url.save
          { status: :success, message: view_context.full_url(new_url) }
        else
          { status: :error, message: new_url.errors.full_messages }
        end
    end

    render json: urls
  end

end
