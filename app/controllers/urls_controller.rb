# controllers/url_controller.rb
class UrlsController < ApplicationController
  before_action :set_url, only: [:edit, :update, :destroy]
  before_action :set_url_friendly, only: [:show]
  before_action :ensure_signed_in

  # GET /urls
  # GET /urls.json
  def index
    @urls = Url.where(group: current_user.context_group)
    @url = Url.new
  end

  # GET /urls/1
  # GET /urls/1.json
  def show
    @url_identifier = @url.id

    @clicks = {
      hrs24: @url.clicks_hrs24,
      days7: @url.clicks_days7,
      days30: @url.clicks_days30,
      alltime: @url.clicks_alltime
    }
    
    @best_day = @url.best_day
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

  # GET /urls/new
  def new
    @url = Url.new
    @url_identifier = Time.now.to_ms
    respond_to do |format|
      format.js { render layout: false }
    end
  end

  # POST /urls
  # POST /urls.json
  def create
    @url_identifier = params[:new_identifier]
    @url = Url.new(url_params)
    @url.group = current_user.context_group

    respond_to do |format|
      if @url.save
        format.html do
          redirect_to urls_path, notice: 'Url was successfully created.'
        end
        format.js { render :show }
      else
        format.js { render :edit }
      end
    end
  end

  # PATCH/PUT /urls/1
  # PATCH/PUT /urls/1.json
  def update
    respond_to do |format|
      if @url.update(url_params)
        format.js   { render :show }
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
      format.html do
        redirect_to urls_url, notice: 'Url was successfully destroyed.'
      end
      format.js { render layout: false }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_url
    @url = Url.find(params[:id])
    @url_identifier = @url.id
  end

  def set_url_friendly
    @url = Url.find_by(keyword: params[:id])
    @url_identifier = @url.id
  end

  # Never trust parameters from the scary internet,
  # only allow the white list through.
  def url_params
    params.require(:url).permit(:url, :keyword, :group_id, :modified_by)
  end
end
