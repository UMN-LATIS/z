class BatchDeleteController < ApplicationController
  def new
    @urls = Url
            .where(keyword: params[:keywords])

    respond_to do |format|
      format.html
      format.js { render 'batch_delete/new', layout: false }
    end
  end

  def create
    Url.where(keyword: params[:keywords]).destroy_all
    respond_to do |format|
      format.js do
        redirect_to urls_path
      end
    #
    # respond_to do |format|
    #   if
    #     format.js do
    #       redirect_to urls_path
    #     end
    #   else
    #     format.js { render 'batch_delete/new', layout: false }
    #   end
    end
  end
end
