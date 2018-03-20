class DbmsController < ApplicationController
  before_action :set_dbm, only: [:index_things]
  load_and_authorize_resource

  def index
    @dbm_s4s = current_user.search_for_existing_dbms_type("DbmS4")
    @dbm_ontotext_legs = current_user.search_for_existing_dbms_type("DbmOntotextLeg")
    @dbm_arangos = current_user.search_for_existing_dbms_type("DbmArango")
    @dbm_graphdbs = current_user.search_for_existing_dbms_type("DbmGraphdb")
  end

  def index_things
    @things = @dbm.find_things
  end


  private

  def set_dbm
    @dbm = Dbm.find(params[:id])
  end

end
