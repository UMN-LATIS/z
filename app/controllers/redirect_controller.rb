class RedirectController < ActionController::Base
  def index
    url = Url.find_by(keyword: params[:keyword])

    if url.nil?
      redirect_to root_path
    else
      redirect_to(url.url)
      browser = Browser.new(request.user_agent, accept_language: "en-us")
      if(!browser.bot?)
        url.add_click!
        begin
          Resque.enqueue(GeoClickJob, url.id, request.remote_ip, Time.now)
        rescue => ex
          url.add_geo_click!(request.remote_ip, Time.now)
        end
      end
    end
  end
end
