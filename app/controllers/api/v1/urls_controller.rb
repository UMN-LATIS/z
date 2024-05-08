class Api::V1::UrlsController < Api::V1::BaseController
  def show
    # the `id` param actually the keyword
    keyword = params[:id]

    # get the url with the keyword
    url = Url.find_by(keyword:)

    # if there's no url, return 404
    if url.blank?
      render json: { status: :error, message: 'URL not found' }, status: :not_found
      return
    end

    # if the url's group doesn't have the current user as a member
    # then return 403
    if url.group.users.exclude?(@current_user)
      render json: { status: :error, message: 'Unauthorized access' }, status: :forbidden
      return
    end

    render json: { status: :success, message: url }
  end

  def create
    urls = @payload['urls']

    urls.each do |url|
      # Find group_id to use for new URL
      if url['collection']
        group_id = @current_user.groups.find_by(name: url['collection']).try(:id)
        if group_id.blank?
          url['result'] = { status: :error, message: 'Cannot find collection with that name.' }
          next
        end
      else
        group_id = @current_user.default_group_id
      end

      new_url = Url.new(url: url['url'], keyword: url['keyword'], group_id:)

      url['result'] =
        if new_url.save
          { status: :success, message: view_context.full_url(new_url) }
        else
          { status: :error, message: new_url.errors.full_messages }
        end
    end

    render json: urls
  end

  def update
    current_keyword = params[:id]

    url = Url.find_by(keyword: current_keyword)

    # if there's no url, return 404
    if url.blank?
      render json: { status: :error, message: 'URL not found' }, status: :not_found
      return
    end

    # if the url's group doesn't have the current user as a member
    # then return 403
    if url.group.users.exclude?(@current_user)
      render json: { status: :error, message: 'Unauthorized access' }, status: :forbidden
      return
    end

    # don't permit keyword changes
    if @payload['keyword'] && @payload['keyword'] != current_keyword
      render json: { status: :error, message: 'Cannot change keyword' }, status: :bad_request
      return
    end

    # update url with payload
    url.url = @payload['url']
    url.save

    render json: { status: :success, message: url }
  end
end
