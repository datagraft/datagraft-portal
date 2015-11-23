class DashboardController < ApplicationController
  before_filter :authenticate_user!

  def index
    if params[:search]
      query = current_user.search_dashboard_things(params[:search])
    else
      query = current_user.dashboard_things
    end

    @things = {
      'all' => query,
      'datapages' => query.where(type: 'DataPage'),
      'transformations' => query.where(type: 'Transformation'),
      'other' => query.where.not(type: ['DataPage', 'Transformation'])
      }

    # get active tab
    @activeTab = @things.has_key?(params[:projects_active_tab]) ? params[:projects_active_tab] : 'all'

    # add pagination
    @things.each do |key, query|
      @things[key] = query.paginate(:page => params['projects_page_'+key], :per_page => 12)
    end

    # get user stars
    stars = current_user.stars.order(created_at: :desc).includes(:thing).limit(10)

    # bonsoir bonsoir
    publicThings = Thing.where(user: current_user, public: true).order(updated_at: :desc).limit(10)

    @activityFeed = (stars | publicThings).sort do |a,b|
      b[:updated_at] <=> a[:updated_at]
    end
  end
end
