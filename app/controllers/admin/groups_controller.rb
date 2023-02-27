# controllers/groups_controller.rb
class Admin::GroupsController < ApplicationController
  before_action :ensure_signed_in
  before_action :ensure_is_admin

  def index
    @groups = Group.not_default
    authorize @groups unless @groups.nil?
  end
end
