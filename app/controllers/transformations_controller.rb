class TransformationsController < ThingsController

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

  private
    def destroyNotice
      "The transformation was successfully destroyed"
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def transformation_params
      params.require(:transformation).permit(
       :name, :public, :name, :code, :description)
       # :name, :public, :name, :code, :description).permit!
       # :name, :public, :name, :code, :description, metadata => [:description, 'dcat:keywords'], :configuration)
    end

end
