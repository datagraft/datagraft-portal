class DashboardController < ApplicationController
  before_filter :authenticate_user!


  # TODO: there is an intense amount of requests coming to this function - we might want to think to optimise it or throttle the requests
  def index
    if params[:search]
      query_things = current_user.search_dashboard_things(params[:search])
      query_catalogues = current_user.search_dashboard_catalogues(params[:search])
    else
      query_things = current_user.dashboard_things
      query_catalogues = current_user.dashboard_catalogues
    end

    @things = {
      'all' => query_things,
      'catalogues' => query_catalogues,
      'datapages' => query_things.where(type: 'DataPage'),
      'transformations' => query_things.where(type: 'Transformation'),
      'other' => query_things.where.not(type: ['DataPage', 'Transformation'])
      }

    # get active tab
    @activeTab = @things.has_key?(params[:projects_active_tab]) ? params[:projects_active_tab] : 'all'

    # add pagination; TODO: This code is very slow because it always retrieves everything from the DB
    @things.each do |key, query|
      if key == 'all'
        things_and_catalogues = query_catalogues + query_things

        # so this is how the magic happens...
        things_and_catalogues.sort_by! do |thing|
          -thing.stars_count
        end

        current_page = params['projects_page_'+key] ? Integer(params['projects_page_'+key]) : 1;
        per_page = params['per_page'] ? Integer(params['per_page']) : 12;

        @things[key] = WillPaginate::Collection.create(current_page, per_page, things_and_catalogues.length) do |pager|
          start = start = (current_page-1)*per_page
          pager.replace(things_and_catalogues[start, per_page])
        end
      else
        @things[key] = query.paginate(:page => params['projects_page_'+key], :per_page => 12)
      end

    end

    # get user stars
    stars = current_user.stars.order(created_at: :desc).includes(:thing).limit(10)
    catalogue_stars = current_user.catalogue_stars.order(created_at: :desc).includes(:catalogue).limit(10)

    # bonsoir bonsoir 
    # добър вечер, драги приятелю
    publicThings = Thing.where(user: current_user, public: true).order(updated_at: :desc).limit(10)
    publicCatalogues = Catalogue.where(user: current_user, public: true).order(updated_at: :desc).limit(10)

    @activityFeed = (stars | publicThings | catalogue_stars | publicCatalogues).sort do |a,b|
      b[:updated_at] <=> a[:updated_at]
    end
  end
end
