require_relative 'boot'

require 'rails/all'

require 'roo' #Used for viewing Excel files

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Datagraft
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # We don't need it now but it may be usefull later
    # config.autoload_paths << Rails.root.join('lib')

    # Do not swallow errors in after_commit/after_rollback callbacks.
#    config.active_record.raise_in_transactional_callbacks = true
    config.action_controller.allow_forgery_protection = false
    
    Gravatarify.options[:default] = 'monsterid' # beautiful monsters by default
    Gravatarify.options[:rating] = 'x' # allows x classified avatars
    Gravatarify.options[:secure] = true # security is our primary concern
    Gravatarify.options[:filetype] = :png # png > jpeg for small avatars
    
    config.to_prepare do
        Doorkeeper::ApplicationsController.layout "application" 
        Doorkeeper::AuthorizationsController.layout "application" 
        Doorkeeper::AuthorizedApplicationsController.layout "application" 

        require 'multi_json'
        MultiJson.use :yajl
    end
    
    Refile.store ||= Refile::Backend::FileSystem.new("/tmp/refile_uploads/store".to_s)
    Refile.cache ||= Refile::Backend::FileSystem.new("/tmp/refile_uploads/cache".to_s)

    config.grafterizer = config_for(:grafterizer)
  end
end
