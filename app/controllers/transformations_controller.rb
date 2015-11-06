class TransformationsController < ApplicationController
  include ApplicationHelper

  #before_action :set_transformation, only: [:show, :edit, :update, :destroy]
  before_filter :set_transformation, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource

  # GET /transformations
  # GET /transformations.json
  def index
    kind = params[:kind].chop.camelcase

    @transformations = Object.const_get(kind).all

    # @transformations = Transformation.all
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

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_transformation
      if params[:username]
        user = User.find_by_username(params[:username]) or not_found
        # p(params[:kind])
        @transformation = user.send(params[:kind]).friendly.find(params[:id])
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
