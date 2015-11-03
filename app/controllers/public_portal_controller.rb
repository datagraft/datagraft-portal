class PublicPortalController < ApplicationController
  before_filter :set_user, only: [:user]

  # GET /:username
  # GET /:username.json
  def user
    if @user.username
      p @user.username
    end
  end

  def explore
    query = Thing.where(:public => true)

    if params[:search]
      #query = query.where('name LIKE ?', params[:search]) 
      # query = query.basic_search(params[:search])
      query = query.fuzzy_search(name: params[:search])
    end

    ActiveRecord::Base.connection.execute("SELECT set_limit(0.1);")

    @things = query.includes(:user).paginate(:page => params[:page], :per_page=>30)

    render layout: "explore"
  end

  private

    def set_user
      @user = User.find_by_username(params[:username]) or not_found
    end

    def not_found
      raise ActionController::RoutingError.new('Not Found')
    end
end
