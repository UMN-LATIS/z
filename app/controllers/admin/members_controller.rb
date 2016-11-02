class Admin::MembersController < ApplicationController
  before_action :ensure_signed_in
  before_action :ensure_is_admin


  def index
    @admins = User.where(admin: true)
    authorize :admin_membership
  end

  def new
    render json: UserLookupService.new(
               query: params[:search_terms],
               query_type: 'all' #todo query_type: params[:search_type]
           ).search
  end

  def create
    authorize :admin_membership
    member = User.where(uid: params[:uid]).first
    member = User.create(user_params) unless member
    member.admin = true
    member.save
    respond_to do |format|
      if member.admin?
        format.js { render inline: "location.reload();" }
      else
        format.html { render :new }
        format.json { render json: member.errors, status: :unprocessable_entity }
        format.js { render :edit }
      end
    end
  end


  def destroy
    @member = User.find(params[:id])
    authorize :admin_membership
    @member.admin = false
    @member.save
    respond_to do |format|
      format.html { redirect_to admins_url, notice: 'Admin membership was successfully updated, user removed.' }
      format.json { head :no_content }
      format.js { render :layout => false }
    end

  end

  private

  def user_params
    params.permit(:uid)
  end

end
