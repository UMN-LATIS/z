class Admin::AuditsController < ApplicationController
  before_action :ensure_signed_in
  before_action :set_admin_view

  def index
    @audits = Audit.select('id, item_type, item_id, event, whodunnit, created_at')
  end

  # GET /audits/1
  # GET /audits/1.json
  def show

    a = Audit.find(params[:id])
    b = a.item_type.constantize.find(a.item_id)

    @objs = [b.versions[0].reify, b.versions[1].reify]



   # b.versions.each do |version|
   #   @objs << version.reify
   # end



    respond_to do |format|
      format.html
      format.js { render layout: false }
    end
  end

end