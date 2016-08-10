class Users::RegistrationsController < Devise::RegistrationsController
  before_filter :configure_sign_up_params, only: [:create]
  before_filter :configure_account_update_params, only: [:update]

  # GET /resource/sign_up
  def new
    fill_infos_from_omniauth
    super
  end

  # POST /resource
  def create
    fill_infos_from_omniauth
    super do 
      if data = session['devise.facebook_data']
        puts "lol"
        resource.uid = data['uid']
        resource.name = data['info']['name']
        resource.image = data['info']['image']
        resource.provider = data['provider']
        resource.password = Devise.friendly_token[0,20]
        resource.skip_confirmation! if resource.respond_to?(:skip_confirmation)
        resource.save
      elsif data = session['devise.github_data']
        puts "github"
        p data
        resource.uid = data['uid']
        resource.provider = data['provider']
        resource.name = data['info']['name']
        rawInfo = data['extra']['raw_info']
        resource.website = rawInfo['blog']
        resource.organization = rawInfo['company']
        resource.place = rawInfo['location']
        resource.image = data['info']['image']
        resource.password = Devise.friendly_token[0,20]
        resource.skip_confirmation! if resource.respond_to?(:skip_confirmation)
        resource.save
      end

    end
  end

  # GET /resource/edit
  # def edit
  #   super
  # end

  # PUT /resource
  # def update
  #   super
  # end

  # DELETE /resource
  # def destroy
  #   super
  # end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  protected

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_up_params
     devise_parameter_sanitizer.permit(:sign_up, keys: [:username, :name, :organization, :website, :place, :terms_of_service])
  end

  # If you have extra params to permit, append them to the sanitizer.
  def configure_account_update_params
     devise_parameter_sanitizer.permit(:account_update, keys: [:name, :organization, :website, :place])
  end

  def after_update_path_for(resource)
    p resource['username']
    '/'+resource['username']
  end

  def fill_infos_from_omniauth
    @facebookRegistration = !session['devise.facebook_data'].nil?
    @githubRegistration = !session['devise.github_data'].nil?
  end
  # The path used after sign up.
  # def after_sign_up_path_for(resource)
  #   super(resource)
  # end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end
end
