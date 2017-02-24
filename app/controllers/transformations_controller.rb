class TransformationsController < ThingsController
  include QuotasHelper

  # POST /:username/:resource/
  def create
    unless quota_room_for_new_transformations_count?(current_user)
      respond_to do |format|
        format.html { redirect_to quotas_path}
        # json error code to be discussed. :upgrade_required, :insufficient_storage
        format.json { render json: { error: flash[:error]}, status: :insufficient_storage}
      end
    else
      super
    end
  end


  # GET /transform
  def transform
    authenticate_user!

    if !session[:tmp_api_key] || (session[:tmp_api_key]['date'] < 1.day.ago)
      api_result = current_user.new_ontotext_api_key(true)
      session[:tmp_api_key] = {
        'key' => api_result['api_key'] + ':' + api_result['secret'],
        'date' => DateTime.now
        }
    end

    @key = session[:tmp_api_key]['key']
  end

  def show
    @grafterizerPath = Rails.configuration.grafterizer['publicPath']
    @publisherId = @transformation.user.username
    @transformationID = @transformation.slug
    super
  end

  def edit
    authorize! :update, @thing
    @grafterizerPath = Rails.configuration.grafterizer['publicPath']
    @publisherId = current_user.username
    @transformationID = @transformation.id
  end


  private
  def destroyNotice
    "The transformation was successfully destroyed"
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def transformation_params
    params.require(:transformation).permit(:name, :public, :code, :description)
  end

  def transformation_params_partial
    params.permit(:transformation, :name, :public, :code, :description)
  end

end
