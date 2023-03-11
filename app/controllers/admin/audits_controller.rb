class Admin::AuditsController < ApplicationController
  before_action :ensure_signed_in
  before_action :ensure_is_admin

  def index
    # grab the first audit so we can authorize current_user against it.
    # the @audits array is not used by datatables for rendering. It is only
    # used for aithorizating current user
    @audits = Audit.first
    authorize @audits unless @audits.nil?

    respond_to do |format|
      format.html
      format.json { render json: AdminAuditDatatable.new(params, view_context:) }
    end
  end
end
