class RedirectController < ActionController::Base
  def index
    url = Url.find_by(keyword: params[:keyword])
    if url.nil?
      redirect_to root_path
    else
      url.add_click!(request.location)
      redirect_to(url.url)
    end
  end
end
