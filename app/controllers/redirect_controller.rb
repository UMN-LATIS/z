class RedirectController < ActionController::Base
  def index
    url = Url.find_by(keyword: params[:keyword])
    if url.nil?
      redirect_to root_path
    else
      redirect_to(url.url)
      url.add_click!(request.location)
    end
  end
end
