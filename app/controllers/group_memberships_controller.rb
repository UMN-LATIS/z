class GroupMembershipsController < ApplicationController
  before_action :set_params, only: %i[show index update create destroy]
  before_action :ensure_signed_in

  def index
  end

  def new
    render json: UserLookup.new(
      query: params[:search_terms],
      query_type: "all"
    ).search
  end

  def create
    member = User.find_or_create_by(uid: params["uid"])
    @group.add_user(member)
    respond_to do |format|
      if @group.user?(member)
        # rubocop: disable Rails/RenderInline
        format.js { render inline: "location.reload();" }
        format.json do
          render json: group_member_as_json(member), status: :created,
            location: group_members_url(@group)
        end
        # rubocop: enable Rails/RenderInline
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
      format.html { redirect_to groups_url, notice: "Group was successfully updated, user removed." }
      format.json { head :no_content }
      format.js { render layout: false }
    end
  end

  private

  def group_member_as_json(member)
    {
      id: member.id,
      uid: member.uid,
      display_name: member.display_name,
      internet_id: member.internet_id,
      email: member.email,
      admin: member.admin,
      created_at: member.created_at,
      updated_at: member.updated_at
    }
  end

  def set_params
    @group = Group.find(params[:group_id])
    authorize @group unless @group.nil?
    @group_identifier = @group.id
    @members = @group.users
  end

  def user_params
    params.permit(:uid)
  end
end
