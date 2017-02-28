class UrlsDatatableController < ApplicationController
  def index
    respond_to do |format|
      format.json do
        render json: UrlDatatable.new(view_context, current_user: current_user)
      end
    end
  end
end
