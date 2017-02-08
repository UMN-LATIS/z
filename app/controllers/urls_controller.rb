# controllers/url_controller.rb
class UrlsController < ApplicationController
  before_action :set_url, only: [:edit, :update, :destroy]
  before_action :set_url_friendly, only: [:show]
  before_action :ensure_signed_in

  # GET /urls
  # GET /urls.json
  def index
    @group = Group.find(current_user.context_group_id)

    @urls =
      Url.created_by_id(current_user.context_group_id).not_in_any_transfer_request
    @pending_transfer_requests_to =
      TransferRequest.where(to_group_id: current_user.context_group_id)

    @pending_transfer_requests_from =
      TransferRequest.where(from_group_id: current_user.context_group_id)
    @url = Url.new
  end

  # GET /urls/1
  # GET /urls/1.json
  def show
    require 'barby'
    require 'barby/barcode/qr_code'
    require 'barby/outputter/svg_outputter'

    @barcode = Barby::QrCode.new(view_context.full_url(@url))
    @barcode_svg = Barby::SvgOutputter.new(@barcode)
    @barcode_svg.xdim = 5

    @url_identifier = @url.id

    @clicks = {
      hrs24:
        @url.clicks.group_by_time_ago(24.hours, '%I:%M%p'),
      days7:
        @url.clicks.group_by_time_ago(7.days, '%m/%d'),
      days30:
        @url.clicks.group_by_time_ago(30.days, '%m/%d'),
      alltime:
        @url.clicks.group_by_time_ago(
          ((Time.now - @url.created_at) / 60 / 60 / 24).days,
          '%m/%Y'
        ),
      regions:
        @url.clicks.group(:country_code).count.to_a
    }

    @best_day = @url.clicks.max_by_day

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
    @empty_url = Url.new

    respond_to do |format|
      if @url.save
        format.html do
          redirect_to urls_path, notice: 'Url was successfully created.'
        end
        format.js { render :create }
      else
        format.js { render :new }
      end
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
      format.html do
        redirect_to urls_url, notice: 'Url was successfully destroyed.'
      end
      format.js { render layout: false }
    end
  end

  # GET /urls/:keyword/:destination
  # Get /urls/ryan/transfer_request
  def keyword_filter
    @keyword = params[:keyword]
    @destination = params[:destination]
    @urls = Url
            .by_keyword(@keyword)
            .created_by_id(current_user.context_group_id)
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_url
    @url = Url.find(params[:id])
    authorize @url unless @url.nil?
    @url_identifier = @url.id
  end

  def set_url_friendly
    @url = Url.find_by(keyword: params[:id])
    authorize @url unless @url.nil?
    @url_identifier = @url.id
  end

  # Never trust parameters from the scary internet,
  # only allow the white list through.
  def url_params
    params.require(:url).permit(:url, :keyword, :group_id, :modified_by)
  end
end
