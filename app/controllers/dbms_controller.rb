class DbmsController < ApplicationController

  def index
    @dbms = current_user.dbms
  end

  def new
    @dbm = Dbm.new
  end
  
end
