class TransformationsController < ThingsController
  include QuotasHelper
  wrap_parameters :transformation, include: [:name, :public, :code, :description]

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

  # POST /:username/transformations/:id/fork
  def fork
    # Check if quota is broken
    quota_ok = quota_room_for_new_transformations_count?(current_user)

    if quota_ok
      super
    else
      respond_to do |format|
        format.html { redirect_to quotas_path}
        # json error code to be discussed. :upgrade_required, :insufficient_storage
        format.json { render json: { error: flash[:error]}, status: :insufficient_storage}
      end
    end
  end

  # GET /:username/transformation/:id/download
  def download
    set_thing
    authorize! :read, @thing

    send_data @thing.code, filename: "#{@thing.slug}_code.json"
  end


  # GET /transform
  def transform
    authenticate_user!

    #if !session[:tmp_api_key] || (session[:tmp_api_key]['date'] < 1.day.ago)
    #  api_result = current_user.new_ontotext_api_key(true)  ## TODO Fix this code ... 'new_ontotext_api_key' does  not exist
    #  session[:tmp_api_key] = {
    #    'key' => api_result['api_key'] + ':' + api_result['secret'],
    #    'date' => DateTime.now
    #    }
    #end

    #@key = session[:tmp_api_key]['key']
  end

  # POST ':username/transformations/:id/execute/:type/' => 'transformations#execute'
  # POST ':username/transformations/:id/execute/:type/:file_id' => 'transformations#execute'
  def execute
    ok = false
    set_thing
    authorize! :read, @thing
    type = params['type']

    known_type = false
    if type == 'pipe'
      known_type = true
      ret_type = 'application/csv'
    elsif type == 'graft'
      known_type = true
      ret_type = 'application/n-triples'
    else
      puts "Transformation cannot execute type #{type}"
      return head(:unprocessable_entity)
    end

    if params["publish_file"] != nil
      @thing.file = params["publish_file"]
      begin
        out_file = @thing.transform(@thing.file, type)
        ok = true
      rescue => e
        puts "Could transform uploaded file ... #{e}"
      end
    elsif params["file_id"] != nil
      begin
        in_file = current_user.filestores.friendly.find(params['file_id'])
        out_file = @thing.transform(in_file.file, type)
        ok = true
      rescue => e
        puts "Could transform file_id ... #{e}"
      end
    end

    if ok
      send_file out_file.download.path, type: ret_type
    else
      return head(:unprocessable_entity)
    end

  end

  def new
    @grafterizerPath = Rails.configuration.grafterizer['publicPath']
    super
  end

  def show
    @grafterizerPath = Rails.configuration.grafterizer['publicPath']
    @publisherId = @transformation.user.username
    @transformationID = @transformation.slug
    @transformationJSON = @transformation.configuration.to_json
    @transformationMeta = @transformation.to_json(:except => [:configuration])
#    render_to_string(template: 'things/show.json.jbuilder', locals: {thing: @transformation})
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
