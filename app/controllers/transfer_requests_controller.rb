class TransferRequestsController < ApplicationController
  before_action :set_transfer_request,
                only: [:edit, :update, :destroy, :show, :confirm]
  def index
    @transfer_requests_to =
      TransferRequest.where(to_group_id: current_user.id)
    @transfer_requests_from =
      TransferRequest.where(from_group_id: current_user.id)
  end

  def confirm
    redirect_to urls_path if @transfer_request.approve!
  end

  def new
    @transfer_request = TransferRequest.new

    @urls = Url
            .created_by_id(current_user.context_group_id)
            .where(keyword: params[:keywords])
            .order('created_at DESC')

    @transfer_request.urls = @urls

    respond_to do |format|
      format.html
      format.js { render layout: false }
    end
  end

  def create
    @transfer_request = TransferRequest.new(
      from_group_id: current_user.context_group_id
    )

    @transfer_request.to_group_id =
      User.find_or_create_by(
        uid: params['transfer_request']['to_group']
      ).context_group_id

    @urls = Url
            .created_by_id(current_user.context_group_id)
            .where(keyword: params[:keywords])
            .order('created_at DESC')

    @transfer_request.urls = @urls

    respond_to do |format|
      if @transfer_request.save
        format.js do
          redirect_to urls_path if @transfer_request.save
        end
      else
        format.js { render :new }
      end
    end
  end

  def destroy
    redirect_to urls_path if @transfer_request.reject!
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_transfer_request
    @transfer_request = TransferRequest.find(params[:id])
  end

end
