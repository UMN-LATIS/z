# controllers/groups_controller.rb
class GroupsController < ApplicationController
  before_action :set_group, only: [:show, :edit, :update, :destroy]
  before_action :ensure_signed_in

  def index
    # Remove the 'yourself' group from your list of groups
    # as you don't need to see it and it's permanent.
    # This group will always be your first group.
    @groups =
      current_user.groups - [current_user.groups.first]
    @group = Group.new
  end

  def show
    @group_identifier = @group.id
    respond_to do |format|
      format.js { render layout: false }
    end
  end

  def new
    @group = Group.new
    @group_identifier = Time.now.to_ms
    respond_to do |format|
      format.js { render layout: false }
    end
  end

  def create
    @group_identifier = params[:new_identifier]
    @group = Group.new(group_params)
    @group.users << current_user
    respond_to do |format|
      if @group.save
        # Since user gets updated (with a new group), a
        # new sign in will be necessary
        sign_in current_user

        format.js { render :create }
      else
        format.js { render :edit }
      end
    end
  end

  def edit
    @group_identifier = @group.id
    respond_to do |format|
      format.js { render layout: false }
    end
  end

  def update
    respond_to do |format|
      if @group.update(group_params)
        format.js { render :update }
      else
        format.js { render :edit }
      end
    end
  end

  def destroy
    return if @group.urls.present?

    @group.destroy

    # It's possible that the current_user in the DB has changed by
    # removing a group but the user remains unchanged in memory.
    # It will be signified by the context_group_id
    # being the same as the one that was just destroyed (which is
    # not valid), so we need to re-signin the current user
    sign_in current_user if current_user.context_group_id == @group.id

    respond_to do |format|
      format.js   { render layout: false }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_group
    @group = Group.find(params[:id])
    authorize @group unless @group.nil?
    @group_identifier = @group.id
  end

  # Never trust parameters from the scary internet, only allow the white list
  # through.
  def group_params
    params.require(:group).permit(:name, :description)
  end
end
