class TransformationsController < ApplicationController
  include ApplicationHelper

  #before_action :set_transformation, only: [:show, :edit, :update, :destroy]
  # before_filter :authenticate_user!, only: [:edit, :udate, :destroy, :star, :unstar]
  before_filter :set_transformation, only: [:show, :edit, :update, :destroy, :star, :unstar]
  load_and_authorize_resource

  # GET /transformations
  # GET /transformations.json
  def index
    # @transformations = []
    # kind = params[:kind].chop.camelcase
    # @transformations = Object.const_get(kind).all
    if user_signed_in? && current_user.username == params[:username]
      respond_to do |format|
        @transformations = current_user.transformations
        format.html
        format.json { render json: @transformations }
      end
      

    else
      index_public
    end

    # @api_keys = current_user.api_keys
    # @transformations = Transformation.all
    # if params[:username]
    # user = User.find_by_username(params[:username]) or not_found
    # p(params[:kind])
    # @transformation = user.send(params[:kind]).friendly.find(params[:id])
    # @transformation = user.transformations.friendly.find(params[:id])
    # end
  end

  def index_public
    user = User.find_by_username(params[:username]) or not_found
    @things = user.transformations.where(public: true).paginate(:page => params[:page], :per_page=>30)
    respond_to do |format|
      format.html { render 'public_portal/explore' } #, layout: 'explore'}
      format.json { render json: @things }
    end
  end

  # GET /transformations/1
  # GET /transformations/1.json
  def show
    puts @transformation.versions
    #if request.path != transformation_path(@transformation)
    #  return redirect_to @transformation, :status => :moved_permanently
    #end
  end

  # GET /transformations/new
  def new
    @transformation = Transformation.new
  end

  # GET /transformations/1/edit
  def edit
  end

  # POST /transformations
  # POST /transformations.json
  def create
    @transformation = Transformation.new(transformation_params)
    # deal with it
    @transformation.name = Bazaar.object if @transformation.name.blank?
    @transformation.user = current_user

    respond_to do |format|
      if @transformation.save
        format.html { redirect_to thing_path(@transformation), notice: 'Transformation was successfully created.' }
        format.json { render :show, status: :created, location: thing_path(@transformation) }
      else
        format.html { render :new }
        format.json { render json: @transformation.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /transformations/1
  # PATCH/PUT /transformations/1.json
  def update
    respond_to do |format|
      if @transformation.update(transformation_params)
        format.html { redirect_to thing_path(@transformation), notice: 'Transformation was successfully updated.' }
        format.json { render :show, status: :ok, location: thing_path(@transformation) }
      else
        format.html { render :edit }
        format.json { render json: @transformation.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /transformations/1
  # DELETE /transformations/1.json
  def destroy
    @transformation.destroy
    respond_to do |format|
      format.html { redirect_to transformations_path, notice: 'Transformation was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def star
    current_user.star(@transformation)
    respond_to do |format|
      format.html { redirect_to thing_path(@transformation), notice: 'Thank you so much <3' }
      format.json { head :no_content }
    end
  end

  def unstar
    current_user.unstar(@transformation)
    respond_to do |format|
      format.html { redirect_to thing_path(@transformation), notice: 'No regrets' }
      format.json { head :no_content }
    end
  end

  def transform
    authenticate_user!

    if !session[:tmp_api_key] || (session[:tmp_api_key]['date'] < 1.day.ago)
      api_result = current_user.new_ontotext_api_key(true)
      session[:tmp_api_key] = {
        key: api_result['api_key'] + ':' + api_result['secret'],
        date: DateTime.now
        }
    end

    @key = session[:tmp_api_key]['key']
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_transformation
    if params[:username]
      user = User.find_by_username(params[:username]) or not_found
      # p(params[:kind])
      # @transformation = user.send(params[:kind]).friendly.find(params[:id])
      @transformation = user.transformations.friendly.find(params[:id])
    else
      @transformation = Transformation.find(params[:id])
    end
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def transformation_params
    params.require(:transformation).permit(:public, :name, :code)
  end

  def not_found
    raise ActionController::RoutingError.new('Not Found')
  end
end
