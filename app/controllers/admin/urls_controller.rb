class Admin::UrlsController < ApplicationController
  before_action :set_url, only: %i[show edit update destroy]
  before_action :ensure_signed_in
  before_action :set_admin_view

  def index
    # Filter URLs based on keyword
    @urls = Url.by_keyword(params[:url_filter_keyword])
    authorize @urls unless @urls.nil?
    # If owner filter present, filter further
    @urls = @urls.created_by_name('params[:url_filter_owner]') if params[:url_filter_owner].present?

    respond_to do |format|
      format.html
      format.json { render json: AdminUrlDatatable.new(params, view_context:) }
    end
  end

  # GET /urls/1
  # GET /urls/1.json
  def show
    @url_identifier = @url.id
    respond_to do |format|
      format.html
      format.js { render layout: false }
    end
  end

  def edit
    @url_identifier = @url.id
    respond_to do |format|
      format.html
      format.js { render layout: false }
    end
  end

  # PATCH/PUT /urls/1
  # PATCH/PUT /urls/1.json
  def update
    respond_to do |format|
      if @url.update(url_params)
        format.js   { render :update }
      else
        format.js   { render :edit }
      end
    end
  end

  # DELETE /urls/1
  # DELETE /urls/1.json
  def destroy
    @url.destroy
    respond_to do |format|
      format.json { head :no_content }
      format.js   { render 'urls/destroy', layout: false }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_url
    @url = Url.find(params[:id])
    authorize @url unless @url.nil?
    @url_identifier = @url.id
  end

  # Never trust parameters from the scary internet
  # only allow the allowlist through.
  def url_params
    params.require(:url).permit(:url, :keyword, :group_id, :modified_by, :duration, :time_unit)
  end
end
