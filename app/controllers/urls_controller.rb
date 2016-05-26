class UrlsController < ApplicationController
  before_action :set_url, only: [:show, :edit, :update, :destroy]

  # GET /urls
  # GET /urls.json
  def index
    @urls = Url.all
    @url = Url.new
  end

  # GET /urls/1
  # GET /urls/1.json
  def show
    respond_to do |format|
      format.html
      format.js   { render :layout => false }
   end
  end
  
  def edit
    respond_to do |format|
      format.html
      format.js   { render :layout => false }
   end
  end

  # GET /urls/new
  def new
    @url = Url.new
    @url_identifier = Time.now.to_ms
    respond_to do |format|
      format.html
      format.js   { render :layout => false }
   end
  end

  # POST /urls
  # POST /urls.json
  def create
    @url_identifier = params[:new_identifier]
    @url = Url.new(url_params)

    respond_to do |format|
      if @url.save
        format.html { redirect_to urls_path, notice: 'Url was successfully created.' }
        format.json { render :show, status: :created, location: @url }
      else
        format.html { render :new }
        format.json { render json: @url.errors, status: :unprocessable_entity }
      end
      format.js   { render :layout => false }
    end
  end

  # PATCH/PUT /urls/1
  # PATCH/PUT /urls/1.json
  def update
    @url_identifier = @url.id
    
    respond_to do |format|
      if @url.update(url_params)
        format.html { redirect_to @url, notice: 'Url was successfully updated.' }
        format.json { render :show, status: :ok, location: @url }
      else
        format.html { render :edit }
        format.json { render json: @url.errors, status: :unprocessable_entity }
      end
      format.js   { render :layout => false }
    end
  end

  # DELETE /urls/1
  # DELETE /urls/1.json
  def destroy
    @url.destroy
    respond_to do |format|
      format.html { redirect_to urls_url, notice: 'Url was successfully destroyed.' }
      format.json { head :no_content }
      format.js   { render :layout => false }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_url
      @url = Url.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def url_params
      params.require(:url).permit(:url, :keyword, :group_id, :modified_by)
    end
end
