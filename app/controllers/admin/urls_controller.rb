class Admin::UrlsController < ApplicationController
  def index
    # Find users by x500
    keyword_to_search = "%#{params[:url_keyword].try(:downcase)}%"
    owner_to_search = "%#{params[:url_owner]}%"
    possible_groups = Group.where('name LIKE ?', owner_to_search).map(&:id)

    @urls = Url.where('keyword LIKE ? and group_id IN (?)', keyword_to_search, possible_groups)
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
        format.json { render :show, status: :ok, location: @url }
        format.js   { render :show }
      else
        format.json { render json: @url.errors, status: :unprocessable_entity }
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
      format.js   { render layout: false }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_url
      @url = Url.find(params[:id])
      @url_identifier = @url.id
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def url_params
      params.require(:url).permit(:url, :keyword, :group_id, :modified_by)
    end
end
