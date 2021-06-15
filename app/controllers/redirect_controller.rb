class RedirectController < ActionController::Base
  def index
    url = Url.find_by(keyword: params[:keyword])

    if url.nil?
      raise ActiveRecord::RecordNotFound
    else
      redirect_to(url.url)
      browser = Browser.new(request.user_agent, accept_language: "en-us")
      if(!browser.bot?)
      	url.add_click!(request.remote_ip)
      end
    end
  end
end
