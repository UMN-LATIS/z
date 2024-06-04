# controllers/url_controller.rb
class UrlsController < ApplicationController
  before_action :ensure_signed_in
  before_action :set_url, only: %i[edit update destroy]
  before_action :set_url_friendly, only: [:show]
  before_action :set_group,
                :check_if_user_can_access_group,
                only: %i[index new create]

  # GET /urls
  # GET /urls.json
  def index
    group_ids_to_get = if @group == current_user.context_group
                         current_user.groups.pluck(:id)
                       else
                         [@group.id]
                       end

    # NOTE: the table is actually populated by datatables,
    # so this doesn't really have any visible effect
    @urls = Url.created_by_ids(group_ids_to_get)
               .not_in_pending_transfer_request

    @pending_transfer_requests_to =
      TransferRequest.pending.where(to_group_id: @group.id)

    @pending_transfer_requests_from =
      TransferRequest.pending
                     .where(from_group_id: @group.id)
    @url = Url.new(group_id: @group.id)
  end

  # GET /urls/1
  # GET /urls/1.json
  def show
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
          ((Time.zone.now - @url.created_at) / 60 / 60 / 24).ceil.days,
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

  # GET /urls/new
  def new
    @url = Url.new
    @url_identifier = Time.zone.now.to_ms
    respond_to do |format|
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

  # POST /urls
  # POST /urls.json
  def create
    @url_identifier = params[:new_identifier]
    @url = Url.new(url_params)
    @url.group = @group

    # reset the form using the same group
    @empty_url = Url.new(group: @group)

    respond_to do |format|
      if @url.save
        format.html do
          redirect_to urls_path, notice: 'URL was successfully created.'
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
        format.json { render json: @url }
      else
        format.js   { render :edit }
        format.json { render json: @url.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /urls/1
  # DELETE /urls/1.json
  def destroy
    if @url.destroy
      respond_to do |format|
        format.html { redirect_to urls_url, notice: 'URL was successfully destroyed.' }
        format.js { render layout: false }
        format.json { render json: { success: true, message: "Group deleted." } }
      end
    else
      respond_to do |format|
        format.html { redirect_to urls_url, notice: 'URL could not be deleted.' }
        format.js   { render layout: false }
        format.json { render json: { success: false, errors: @group.errors.full_messages }, status: :unprocessable_entity }
      end
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
    raise ActiveRecord::RecordNotFound if @url.nil?

    authorize @url unless @url.nil?
    @url_identifier = @url.id
  end

  def set_url_friendly
    @url = Url.find_by(keyword: params[:id])
    raise ActiveRecord::RecordNotFound if @url.nil?

    authorize @url unless @url.nil?
    @url_identifier = @url.id
  end

  # Never trust parameters from the scary internet,
  # only permit the allowlist through.
  def url_params
    params.require(:url).permit(:url, :keyword, :group_id, :modified_by)
  end

  def set_group
    # use collection query string if present,
    # or the url's group_id if present.
    # otherwise use current_user's context_group_id
    group_id = params[:collection].presence || params.dig(:url, :group_id) || current_user.context_group_id
    @group = Group.find(group_id)
  end

  def check_if_user_can_access_group
    authorize @group, :update?
  rescue Pundit::NotAuthorizedError
    redirect_to urls_path, alert: "You do not have permission to access this collection. Redirected to your Z-Links."
  end
end
