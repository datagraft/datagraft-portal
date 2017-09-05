class DbmsController < ApplicationController
  load_and_authorize_resource

  def index
    @dbm_s4s = current_user.search_for_existing_dbms_type("DbmS4")
    @dbm_ontotext_legs = current_user.search_for_existing_dbms_type("DbmOntotextLeg")
  end

end
