class UtilityFunctionsController < ThingsController

  private
    def destroyNotice
      "The utility function was successfully destroyed"
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def utility_function_params
        params.require(:utility_function).permit(:public, :name, :metadata, :configuration, :code, :license, :language)
    end

end
