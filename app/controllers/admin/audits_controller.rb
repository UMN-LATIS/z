class Admin::AuditsController < ApplicationController
  before_action :ensure_signed_in
  before_action :set_admin_view

  def index
    # grab the first audit so we can authorize current_user against it.
    # the @audits array is not used by datatables for rendering. It is only
    # used for aithorizating current user
    @audits = Audit.first
    authorize @audits unless @audits.nil?
  end
end
