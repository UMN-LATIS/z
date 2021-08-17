class Admin::AnnouncementsController < ApplicationController
  before_action :set_admin_announcement, only: %i[show edit update destroy]
  before_action :ensure_signed_in
  before_action :set_admin_view
  before_action :ensure_is_admin

  # GET /admin/announcements
  # GET /admin/announcements.json
  def index
    @admin_announcements = Admin::Announcement.all
    authorize @admin_announcements unless @admin_announcements.nil?
  end

  # GET /admin/announcements/1
  # GET /admin/announcements/1.json
  def show
  end

  # GET /admin/announcements/new
  def new
    @admin_announcement = Admin::Announcement.new
  end

  # GET /admin/announcements/1/edit
  def edit
  end

  # POST /admin/announcements
  # POST /admin/announcements.json
  def create
    @admin_announcement = Admin::Announcement.new(admin_announcement_params)

    respond_to do |format|
      if @admin_announcement.save
        format.html { redirect_to admin_announcements_url, notice: 'Announcement was successfully created.' }
      else
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /admin/announcements/1
  # PATCH/PUT /admin/announcements/1.json
  def update
    respond_to do |format|
      if @admin_announcement.update(admin_announcement_params)
        format.html { redirect_to admin_announcements_url, notice: 'Announcement was successfully updated.' }
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /admin/announcements/1
  # DELETE /admin/announcements/1.json
  def destroy
    @admin_announcement.destroy
    respond_to do |format|
      format.html { redirect_to admin_announcements_url, notice: 'Announcement was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_admin_announcement
    @admin_announcement = Admin::Announcement.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the allowlist through.
  def admin_announcement_params
    params.require(:admin_announcement).permit(:title, :body, :start_delivering_at, :stop_delivering_at)
  end
end
