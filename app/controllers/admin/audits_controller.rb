class Admin::AuditsController < ApplicationController
  before_action :ensure_signed_in
  before_action :set_admin_view

  def index
    @audits = Audit.first
    authorize @audits unless @audits.nil?
  end

  # GET /audits/1
  # GET /audits/1.json
  def show
    a = Audit.find(params[:id])
    authorize a unless a.nil?
    b = a.item_type.constantize.find(a.item_id)
    @objs = [b]
    b.versions.each do |version|
      @objs << version.reify
    end
    respond_to do |format|
      format.html
      format.js { render layout: false }
    end
  end

end