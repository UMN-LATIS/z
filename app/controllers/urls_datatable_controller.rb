class UrlsDatatableController < ApplicationController
  before_action :ensure_signed_in

  def index
    respond_to do |format|
      format.json do
        render json: UrlDatatable.new(params, view_context:, current_user:)
      end
    end
  end
end
