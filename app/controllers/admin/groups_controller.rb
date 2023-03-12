# controllers/groups_controller.rb
class Admin::GroupsController < ApplicationController
  before_action :ensure_signed_in
  before_action :ensure_is_admin

  def index
    @groups = Group.not_default
    authorize @groups unless @groups.nil?

    respond_to do |format|
      format.html
      format.json { render json: AdminGroupDatatable.new(params, view_context:) }
    end
  end

  def show
    @group = Group.find(params[:id])
    authorize @group unless @group.nil?

    @users = @group.users.map do |user|
      {
        id: user.id,
        uid: user.uid,
        default_group_id: user.default_group_id,
        internet_id: user.internet_id,
        display_name: user.display_name,
        email: user.email,
        admin: user.admin?
      }
    end

    respond_to do |format|
      format.html
    end
  end
end
