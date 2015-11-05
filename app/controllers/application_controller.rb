class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.json { head :forbidden }
      format.html { render :text => exception.message }
    end
  end

  def users_return_to
    return "je suis un poney"
    # current_user.name
  end

  def after_sign_in_path_for(resource)
    # TODO
    return "/explore"
  end
end
