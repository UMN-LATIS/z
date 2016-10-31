class GroupContextController < ApplicationController
  before_action :set_group, only: [:show]

  def show
    set_group
    current_user.update_context_group_id!(@group.id)

    # Updating the user causes the user to sign out
    # Automatically sign them back in
    sign_in current_user

    redirect_to urls_path
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_group
    @group = Group.find(params[:id])
    authorize @group unless @group.nil?
  end
end
