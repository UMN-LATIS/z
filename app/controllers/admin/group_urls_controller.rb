module Admin
  class GroupUrlsController < ApplicationController
    before_action :ensure_signed_in
    before_action :ensure_is_admin

    def index
      @urls = Url.where(group_id: params[:group_id]).includes(:group)

      authorize @urls unless @urls.nil?

      respond_to do |format|
        format.json { render json: AdminGroupUrlsDatatable.new(params, view_context:) }
      end
    end
  end
end
