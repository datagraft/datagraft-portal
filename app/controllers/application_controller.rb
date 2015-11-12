class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :authenticate_user_from_token!

  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.json { head :forbidden }
      format.html { render 'public_portal/forbidden', status: :forbidden }
    end
  end

  protected

    def users_return_to
      return "je suis un poney"
      # current_user.name
    end

    def after_sign_in_path_for(resource)
      # TODO
      # p session
      stored_location_for(resource) || "/explore"
      # return "/explore"
    end

  private

    def authenticate_user_from_token!
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
