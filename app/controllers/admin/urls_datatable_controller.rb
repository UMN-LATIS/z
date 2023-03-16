class Admin::UrlsDatatableController < ApplicationController
  def index
    respond_to do |format|
      format.json do
        render json: AdminUrlDatatable.new(params, view_context:, current_user:)
      end
    end
  end
end