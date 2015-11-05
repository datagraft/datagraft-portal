class DataDistributionsController < ApplicationController
  before_action :set_data_distribution, only: [:show, :edit, :update, :destroy]

  # GET /data_distributions
  # GET /data_distributions.json
  def index
    @data_distributions = DataDistribution.all
  end

  # GET /data_distributions/1
  # GET /data_distributions/1.json
  def show
  end

  # GET /data_distributions/new
  def new
    @data_distribution = DataDistribution.new
  end

  # GET /data_distributions/1/edit
  def edit
  end

  # POST /data_distributions
  # POST /data_distributions.json
  def create
    @data_distribution = DataDistribution.new(data_distribution_params)
    @data_distribution.user = current_user

    respond_to do |format|
      if @data_distribution.save
        format.html { redirect_to @data_distribution, notice: 'Data distribution was successfully created.' }
        format.json { render :show, status: :created, location: @data_distribution }
      else
        format.html { render :new }
        format.json { render json: @data_distribution.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /data_distributions/1
  # PATCH/PUT /data_distributions/1.json
  def update
    respond_to do |format|
      if @data_distribution.update(data_distribution_params)
        format.html { redirect_to @data_distribution, notice: 'Data distribution was successfully updated.' }
        format.json { render :show, status: :ok, location: @data_distribution }
      else
        format.html { render :edit }
        format.json { render json: @data_distribution.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /data_distributions/1
  # DELETE /data_distributions/1.json
  def destroy
    @data_distribution.destroy
    respond_to do |format|
      format.html { redirect_to data_distributions_url, notice: 'Data distribution was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_data_distribution
      @data_distribution = DataDistribution.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def data_distribution_params
      params.require(:data_distribution).permit(:public, :name, :code, :file)
    end
end
