class Admin::AuditsController < ApplicationController
  before_action :ensure_signed_in
  before_action :set_admin_view

  def index
    # Filter URLs based on keyword
    @audits = Audit.select('id, item_type, item_id, event, whodunnit, created_at')
    x = @audits
    #    authorize @urls unless @urls.nil?
    # If owner filter present, filter further
    #    if params[:url_filter_owner].present?
    #      @urls = @urls.created_by_name('params[:url_filter_owner]')
    #    end
  end

  # GET /audits/1
  # GET /audits/1.json
  def show
    #@url_identifier = @url.id
    respond_to do |format|
      format.html
      format.js { render layout: false }
    end
  end

end