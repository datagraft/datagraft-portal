class PublicPortalController < ApplicationController
  before_filter :set_user, only: [:user]

  # GET /:username
  # GET /:username.json
  def user
    @things = Thing.public_list
      .where(user: @user)
      .paginate(:page => params[:page], :per_page => 30)

    if user_signed_in? && @user == current_user
      @things = @things.unscope(where: :public)
      @ownAccount = true
    end

  end

  def explore

    if params[:search]
      query = Thing.public_search(params[:search])
    else
      query = Thing.public_list
    end
    
    @things = query.paginate(:page => params[:page], :per_page=>30)
    respond_to do |format|
      format.html
      format.json { render template: 'public_portal/explore' }
    end
    # render layout: "explore"
  end

  private

    def set_user
      @user = User.find_by_username(params[:username]) or not_found
    end

    def not_found
      raise ActionController::RoutingError.new('Not Found')
    end
end
