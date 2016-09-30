class FileWizardController < ApplicationController
  include Wicked::Wizard
  steps :file_get, :file_decide

  def new
    authorize! :create, resource
    @filewizard = FileWizard.new
  end

  def destroy
  end

  def show
    @filewizard = FileWizard.find(params[:wiz_id])
  end

  def update
    @filewizard = FileWizard.find(params[:wiz_id])
    @filewizard.update_attributes(params[:file])
    render_wizard @filewizard
  end

private

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
