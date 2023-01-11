# class RedirectController < ActionController::Base
class RedirectController < ApplicationController
  def index
    url = Url.find_by(keyword: params[:keyword])

    if url.nil?
      raise ActiveRecord::RecordNotFound
    else
      redirect_to(url.url, allow_other_host: true)
      browser = Browser.new(request.user_agent, accept_language: "en-us")
      url.add_click!(request.remote_ip) unless browser.bot?
    end
  end
end
