class DashboardController < ApplicationController
  before_filter :authenticate_user!

  def index
    if params[:search]
      query = current_user.search_dashboard_things(params[:search])
    else
      query = current_user.dashboard_things
    end

    @things = query.paginate(:page => params[:projects_page], :per_page=>12) 
  end
end
