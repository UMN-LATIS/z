class Admin::MembersController < ApplicationController
  before_action :set_params, only: [:show, :index, :update, :create, :destroy]
  before_action :ensure_signed_in
  before_action :ensure_is_admin


  def index
    @admins = User.where(:admin => true)
  end

  def new
    render json: UserLookupService.new(
               query: params[:search_terms],
               query_type: 'all' #todo query_type: params[:search_type]
           ).search
  end

  def create
    member = User.where(:uid => params[:uid]).first
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
    @member.admin = false
    @member.save
    respond_to do |format|
      format.html { redirect_to admins_url, notice: 'Admin membership was successfully updated, user removed.' }
      format.json { head :no_content }
      format.js { render :layout => false }
    end

  end

  private

  def set_params
    #@group = Group.find(params[:group_id])
    #@group_identifier = @group.id
    #@members = @group.users
  end

  def user_params
    params.permit(:uid)
  end

end
