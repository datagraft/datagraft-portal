class ApplicationController < ActionController::Base
  include CanCan::ControllerAdditions

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session

  before_action :authenticate_user_from_token_or_doorkeeper!
  after_action :store_location!

  #check_authorization :unless => :do_not_check_authorization?

  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.json { head :forbidden }
      format.html { render 'public_portal/forbidden', status: :forbidden }
    end
  end

  before_action :set_paper_trail_whodunnit

  protected

    # def authenticate_user!
      # return if current_user

      # render json: { errors: ['User is not authenticated!'] }, status: :unauthorized
    # end

    # def users_return_to
      # return "je suis un poney"
      # current_user.name
    # end

    def after_sign_in_path_for(resource)
      # TODO
      # p session
      # p resource
      # throw  current_user_path
      # throw stored_location_for(resource)


      r = request.env['omniauth.origin'] || stored_location_for(resource) || "/explore"
      # store_location_for(:user, request.fullpath)
      session.delete(stored_location_key_for(resource))
      # stored_location_for(resource) || "/explore"
      # return "/explore"
      # prevent redirect loop
      return "/explore" if r == request.referer
      return r
    end

    # def after_sign_in_path_for(resource)
    #   stored_location_for(:user) || root_path
    # end

    def store_location!
      return if current_user
      return unless request.get?
      return if request.path =~ /^\/users\// 
      store_location_for(:user, request.fullpath)
    end

    def user_for_paper_trail
      user_signed_in? ? current_user.username : 'anonymous'
    end

    def not_found
      raise ActionController::RoutingError.new('Not Found')
    end

  private
    def doorkeeper_unauthorized_render_options(error: nil)
      { json: { error: "Not authorized connard" } }
    end

    def do_not_check_authorization?
      respond_to?(:devise_controller?)
    end

    def authenticate_user_from_token_or_doorkeeper!(*scopes)
      # OAuth2 first
      # throw "auinetaunst"
      @_doorkeeper_scopes = scopes.presence || Doorkeeper.configuration.default_scopes
      if valid_doorkeeper_token?
        user = User.find(doorkeeper_token.resource_owner_id)
        # throw user
        if user
          request.env['devise.skip_trackable'] = true
          sign_in user, store: false
          request.env.delete('devise.skip_trackable')
          return
        end
      end

      # Get the values from the headers
      if token = params[:user_token].blank? &&
          request.headers['X-user-token']
        params[:user_token] = token
      end
      
      user_token = params[:user_token].presence

      if user_token
        token = ApiKey.where(key: user_token, enabled: true).first
        # This is maybe not safe for timing attacks but who cares?
        if token
          request.env['devise.skip_trackable'] = true
          sign_in token.user, store: false
          request.env.delete('devise.skip_trackable')
        end
      end
    end
end
