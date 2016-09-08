class RedirectController < ApplicationController
  def index
    url = Url.find_by_keyword(params[:keyword])
    if url.present?
      url.add_click!(request.location)
      redirect_to(url.url)
    else
      redirect_to root_path
    end
  end
end
