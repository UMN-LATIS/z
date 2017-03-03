class Admin::AuditsController < ApplicationController
  before_action :ensure_signed_in
  before_action :set_admin_view

  def index
    @audits = Audit.select('id, item_type, item_id, event, whodunnit, created_at')
  end

  # GET /audits/1
  # GET /audits/1.json
  def show
    respond_to do |format|
      format.html
      format.js { render layout: false }
    end
  end

end