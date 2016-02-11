class UtilityFunctionsController < ThingsController

  private
    def destroyNotice
      "The utility function was successfully destroyed"
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def utilityfunction_params
      params.require(:utilityfunction).permit(:public, :name, :code)
    end

end
