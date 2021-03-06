class PublicPortalController < ApplicationController
  before_action :set_user, only: [:user]
  skip_authorize_resource only: [:user, :explore, :terms, :privacy, :faq]
  skip_authorization_check

  # GET /feedback
  def feedback
    render template: 'public_portal/feedback'
  end

  # GET /about-us
  def about
    render template: 'public_portal/about_us'
  end

  # GET /documentation
  def documentation
    render template: 'public_portal/documentation'
  end

  # GET /terms-of-use
  def terms
    render template: 'public_portal/terms_of_use'
  end

  # GET /privacy-policy
  def privacy
    render template: 'public_portal/privacy_policy'
  end

  # GET /cookie-policy
  def cookie
    render template: 'public_portal/cookie_policy'
  end

  # GET /faq
  def faq
    render template: 'public_portal/faq'
  end

  # GET /:username
  # GET /:username.json
  def user
    @things = Thing.public_list.where(user: @user).paginate(:page => params[:page], :per_page => 12)

    if user_signed_in? && @user == current_user
      things_and_catalogues = Catalogue.where(user: @user) + Thing.public_list.where(user: @user)
      @ownAccount = true
    else
      things_and_catalogues = Catalogue.public_list.where(user: @user) + Thing.public_list.where(user: @user)
    end

    things_and_catalogues.sort_by! do |thing_or_catalogue|
      -thing_or_catalogue.stars_count
    end

    current_page = params[:page] ? Integer(params[:page]) : 1;
    # default page size = 12?
    per_page = params['per_page'] ? Integer(params['per_page']) : 12;

    @things = WillPaginate::Collection.
      create(current_page, per_page, things_and_catalogues.length) do |pager|

        start = start = (current_page-1)*per_page
        pager.replace(things_and_catalogues[start, per_page])

      end

    respond_to do |format|
      format.html { if user_signed_in? && @user == current_user
                       redirect_to edit_user_registration_path
                    else
                       render template: 'public_portal/user'
                    end
                  }
      format.json { render template: 'public_portal/user' }
    end

  end

  def explore
    if params[:search]
      query_things = Thing.public_search(params[:search])
      things_and_catalogues = query_things
      if Flipflop.enabled? :catalogues
        query_catalogues = Catalogue.public_search(params[:search])
        things_and_catalogues += query_catalogues
      end
    else
      query_things = Thing.public_list
      things_and_catalogues = query_things
      if Flipflop.enabled? :catalogues
        query_catalogues = Catalogue.public_list
        things_and_catalogues += query_catalogues
      end
    end

    # TODO: make this into a helper function
    things_and_catalogues.to_a.sort_by! do |thing_or_catalogue|
      -thing_or_catalogue.stars_count
    end

    current_page = params[:page] ? Integer(params[:page]) : 1;
    # default page size = 12?
    per_page = params['per_page'] ? Integer(params['per_page']) : 12;

    @things = WillPaginate::Collection.
      create(current_page, per_page, things_and_catalogues.length) do |pager|

        start = start = (current_page-1)*per_page
        pager.replace(things_and_catalogues[start, per_page])

      end

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
