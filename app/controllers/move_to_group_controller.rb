class MoveToGroupController < ApplicationController
  def new
    @urls = Url
            .where(keyword: params[:keywords])
            .order('created_at DESC')
    @groups = current_user.groups

    respond_to do |format|
      format.html
      format.js { render 'move_to_group/new', layout: false }
    end
  end

  def create
    @from_group_id = current_user.context_group_id
    @to_group = params['Group']

    @to_group_id = Group.where(id: @to_group).take.try(:id)

    @urls = Url
            .where(keyword: params[:keywords])
            .order('created_at DESC')

    respond_to do |format|
      if @urls.update_all(group_id: @to_group_id)
        format.js do
          redirect_to urls_path
        end
      else
        format.js { render 'move_to_group/new', layout: false }
      end
    end
  end
end
