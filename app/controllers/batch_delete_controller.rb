class BatchDeleteController < ApplicationController
  before_action :ensure_signed_in

  def new
    @urls = Url
            .created_by_ids(current_user.groups.pluck(:id))
            .where(keyword: params[:keywords])

    respond_to do |format|
      format.html
      format.js { render 'batch_delete/new', layout: false }
    end
  end

  def create
    Url.created_by_ids(current_user.groups.pluck(:id))
       .where(keyword: params[:keywords])
       .destroy_all
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
