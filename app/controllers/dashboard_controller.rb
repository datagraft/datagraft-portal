class DashboardController < ApplicationController
  before_action :authenticate_user!


  # TODO: there is an intense amount of requests coming to this function - we might want to think to optimise it or throttle the requests
  def index
    if params[:search]
      query_things = current_user.search_dashboard_things(params[:search])
      query_catalogues = current_user.search_dashboard_catalogues(params[:search])
    else
      query_things = current_user.dashboard_things
      query_catalogues = current_user.dashboard_catalogues
    end

    query_things = query_things.includes(:user)
    query_catalogues = query_catalogues.includes(:user)

    @things = {
      'all' => query_things,
      'catalogues' => query_catalogues,
      'datapages' => query_things.where(type: 'DataPage'),
      'transformations' => query_things.where(type: 'Transformation'),
      'queriable_data_stores' => query_things.where(type: 'QueriableDataStore'),
      'queries' => query_things.where(type: 'Query'),
      'other' => query_things.where.not(type: ['DataPage', 'Transformation', 'QueriableDataStore'])
      }

    # get active tab
    @activeTab = @things.has_key?(params[:projects_active_tab]) ? params[:projects_active_tab] : 'all'

    @things.each do |key, query|
      if key == 'all'
        things_and_catalogues = query_catalogues + query_things
        @things[key] = things_and_catalogues
      else
        @things[key] = query
      end
    end

    # get user stars
    stars = Star.order(created_at: :desc).includes(:thing).where('things.public' => true).limit(10)
    # TODO public stars on catalogues on followed users
    catalogue_stars = current_user.catalogue_stars.order(created_at: :desc).includes(:catalogue).limit(10)

    # bonsoir bonsoir 
    # добър вечер, драги приятелю
    # publicThings = Thing.where(user: current_user, public: true).order(updated_at: :desc).includes(:user).limit(10)
    publicThings = Thing.where(public: true).order(updated_at: :desc).includes(:user).limit(10)
    publicCatalogues = Catalogue.where(user: current_user, public: true).order(updated_at: :desc).includes(:user).limit(10)
    @activityFeed = (stars | publicThings | catalogue_stars | publicCatalogues).sort do |a,b|
      b[:updated_at] <=> a[:updated_at]
    end

    @activityFeed = @activityFeed.take(15)

    authorize! :read, @things
  end
end
