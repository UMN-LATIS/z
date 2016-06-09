class GroupsController < ApplicationController
  before_action :set_group, only: [:show, :edit, :update, :destroy]
  before_action :ensure_signed_in


  def index
    @groups = current_user.groups
    @group = Group.new
  end

  def show
    @group_identifier = @group.id
    respond_to do |format|
      format.html
      format.js   { render layout: false }
    end
  end

  def new
    @group = Group.new
    @group_identifier = Time.now.to_ms
    respond_to do |format|
      format.html
      format.js   { render :layout => false }
    end
  end

  def create
    @group_identifier = params[:new_identifier]
    @group = Group.new(group_params)

    respond_to do |format|
      if @group.save
        format.html { redirect_to groups_path, notice: 'Group was successfully created.' }
        format.json { render :show, status: :created, location: @group }
        format.js   { render :show }
      else
        format.html { render :new }
        format.json { render json: @group.errors, status: :unprocessable_entity }
        format.js   { render :edit }
      end

    end

  end

  def edit
    @group_identifier = @group.id
    respond_to do |format|
      format.html
      format.js   { render :layout => false }
    end
  end

  def update
    respond_to do |format|
      if @group.update(group_params)
        format.html { redirect_to @group, notice: 'Group was successfully updated.' }
        format.json { render :show, status: :ok, location: @group }
        format.js   { render :show }
      else
        format.html { render :edit }
        format.json { render json: @group.errors, status: :unprocessable_entity }
        format.js   { render :edit }
      end
    end

  end

  def destroy
    @group.destroy
    respond_to do |format|
      format.html { redirect_to groups, notice: 'Group was successfully destroyed.' }
      format.json { head :no_content }
      format.js   { render :layout => false }
    end
  end


  private
  # Use callbacks to share common setup or constraints between actions.
  def set_group
    @group = Group.find(params[:id])
    @group_identifier = @group.id
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def group_params
    params.require(:group).permit(:name, :description)
  end



end
