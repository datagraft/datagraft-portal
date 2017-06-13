Rails.application.configure do
  config.web_console.development_only = false
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  #  # Enable/disable caching. By default caching is disabled.
  #  if Rails.root.join('tmp/caching-dev.txt').exist?
  #    config.action_controller.perform_caching = true
  #
  #    config.cache_store = :memory_store
  #    config.public_file_server.headers = {
  #      'Cache-Control' => 'public, max-age=172800'
  #    }
  #  else
  #    config.action_controller.perform_caching = false
  #
  #    config.cache_store = :null_store
  #  end

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = true

  config.action_mailer.perform_caching = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Asset digests allow you to set far-future HTTP expiration dates on all assets,
  # yet still be able to expire them through the digest params.
  config.assets.digest = true

  # Adds additional error checking when serving assets at runtime.
  # Checks for improperly declared sprockets dependencies.
  # Raises helpful error messages.
  config.assets.raise_runtime_errors = true
  # Suppress logger output for asset requests.
  config.assets.quiet = true

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true
  
  # Configure the default host and port for the mailer
  deploy_host = ENV["DATAGRAFT_DEPLOY_HOST"] ? ENV["DATAGRAFT_DEPLOY_HOST"] : 'localhost'
  deploy_port = ENV["DATAGRAFT_DEPLOY_PORT"]

  # URL in emails
  if deploy_port then
    # if we provided the port - add to configuration
    config.action_mailer.default_url_options = { host: deploy_host, port: deploy_port}
  else
    # if no port was specified - only use the host name (e.g., in a live deployment)
    config.action_mailer.default_url_options = { host: deploy_host}
  end

  config.web_console.whitelisted_ips = ENV['WEB_CONSOLE_WHITELISTED_IPS'] or '10.0.0.0/8'
  #=========================
  # ==> Mailer Configuration
  # Configure the e-mail address which will be shown in Devise::Mailer,
  # note that it will be overwritten if you use your own mailer class
  # with default "from" parameter.
  config.mailer_sender = ENV["DEVISE_MAILER_SENDER"] or 'datagraft@sintef.no'
  
  #=========================
  config.action_mailer.default_options = {from: 'datagraft@sintef.no'}
  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  # config.file_watcher = ActiveSupport::EventedFileUpdateChecker
  config.action_mailer.perform_deliveries = true
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    :address => "email-smtp.eu-west-1.amazonaws.com",
    :port => 587,
    :user_name => ENV["SES_SMTP_USERNAME"],
    :password => ENV["SES_SMTP_PASSWORD"],
    :authentication => :login,
    :enable_starttls_auto => true
    }

end
