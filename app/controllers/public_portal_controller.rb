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
    @things = Thing.where(:public => true).includes(:user).paginate(:page => params[:page], :per_page=>30)
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
