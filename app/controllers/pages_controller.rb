class PagesController < ApplicationController
  def show
    if valid_page?
      render template: "pages/#{params[:page]}"
    else
      raise ActiveRecord::RecordNotFound
    end
  end

  private
  def valid_page?
    File.exist?(Pathname.new(Rails.root + "app/views/pages/#{params[:page]}.html.erb"))
  end

end