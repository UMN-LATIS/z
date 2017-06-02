class Admin::MembersController < ApplicationController
  before_action :ensure_signed_in
  before_action :ensure_is_admin


  def index
    @admins = User.where(admin: true)
    authorize :admin_membership
  end

  def new
    render json: UserLookup.new(
      query: params[:search_terms],
      query_type: 'all'
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
      if current_user.uid.eql? @member.uid
        ####
        # current user is redirect to signin page if they remove their own admin status,
        # resigning the current user in allows the redirect to urls work properly
        sign_in current_user
        format.html { redirect_to shortener_url, notice: 'Admin Membership: You have successfully removed your administrative privileges and have been routed back to your home page.' }
      else
        format.html { redirect_to admin_members_url, notice: "Admin Membership: #{@member.display_name} (#{@member.internet_id}) has been removed." }
      end
    end

  end

  private

  def user_params
    params.permit(:uid)
  end

end
