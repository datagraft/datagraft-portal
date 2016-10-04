class UpwizardController < ApplicationController
  include Wicked::Wizard
  steps :publish, :decide

  def create
    @upwizard = Upwizard.find(params[:wiz_id])
    authorize! :update, @upwizard
    @upwizard.update_attributes(upwizard_params)
    @upwizard.save
    #byebug
  end

  def index
    #byebug
    upwizard = Upwizard.new  # Create new wizard
    upwizard.user = current_user
    authorize! :create, upwizard
    upwizard.update_attributes(params.permit([:task]))
    upwizard.save

    goto_step = steps.first
    options = request.query_parameters

    options = options.respond_to?(:to_h) ? options.to_h : options
    options = { :controller => wicked_controller,
                :action     => 'show',
                :id         => goto_step || params[:id],
                :wiz_id     => upwizard.id,
                :only_path  => true
               }.merge options
    redirect_to url_for(options)
  end

  def destroy
    byebug
  end

  def show
    @upwizard = Upwizard.find(params[:wiz_id])
    authorize! :read, @upwizard
    #byebug
    render_wizard
  end

  def update
    @upwizard = Upwizard.find(params[:wiz_id])
    authorize! :update, @upwizard
    @upwizard.update_attributes(upwizard_params)
    @upwizard.save
    #byebug
    render_wizard
  end

private

  # Never trust parameters from the scary internet, only allow the white list through.
  def upwizard_params
    params.require(:upwizard).permit([:file, :task])
  end

  def redirect_to_create_filestore
    #redirect_to root_url, notice: "Thank you for #signing up."
  end

  def redirect_to_create_transformation
    #redirect_to root_url, notice: "Thank you for #signing up."
  end

  def redirect_to_create_sparql_endpoint
    #redirect_to root_url, notice: "Thank you for #signing up."
  end

end
