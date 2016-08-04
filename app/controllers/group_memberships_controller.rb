class GroupMembershipsController < ApplicationController
  before_action :set_params, only: [:show, :index, :update, :create, :destroy]
  before_action :ensure_signed_in


  def index
  end

  def new
    render json:
               UserLookupService.new(
                   query: params[:search_terms],
                   query_type: 'all' #query_type: params[:search_type]
               ).search
  end

  def create
    member = User.create(user_params)
    @group.add_user(member)
    respond_to do |format|
      if @group.user?(member)
        format.js { render inline: "location.reload();" }
      else
        format.html { render :new }
        format.json { render json: @group.errors, status: :unprocessable_entity }
        format.js { render :edit }
      end
    end
  end


  def destroy
    @member = User.find(params[:id])
    @group.remove_user(@member)
    respond_to do |format|
      format.html { redirect_to groups_url, notice: 'Group was successfully updated, user removed.' }
      format.json { head :no_content }
      format.js { render :layout => false }
    end

  end

  private

  def set_params
    @group = Group.find(params[:group_id])
    @group_identifier = @group.id
    @members = @group.users
  end

  def user_params
    params.permit(:uid)
  end

end
