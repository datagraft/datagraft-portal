class Dbm < ApplicationRecord
  belongs_to :user
  has_many :dbm_accounts, dependent: :destroy
  has_many :api_keys, dependent: :destroy
  has_many :rdf_repos, dependent: :destroy

  cattr_accessor :supported_repository_types


  def delete_dbm()
  end

  def create_dbm(dbm_account, api_key)
  end

  def update_account(dbm_account)
  end


  # Create and add new API key to the DBM
  def add_key(name, key_pub, key_secret, enabled = true)
    self.save
    api_key = self.api_keys.create()

    api_key.name = name
    api_key.key_pub = key_pub
    api_key.key_secret = key_secret
    api_key.enabled = enabled
    api_key.user = user
    api_key.save

    self.save
    return api_key
  end


  # Delete API key from the DBM
  def delete_key(api_key)
    self.api_keys.find(api_key).destroy
  end


  # The user have added the api_key element
  # This is a hook if dbm needs to synchronize
  def key_added(api_key)
    puts "***** Dbm::key_added()"
  end


  # The user have changed the api_key element
  # This is a hook if dbm needs to synchronize
  def key_updated(api_key)
    puts "***** Dbm::key_updated()"
  end


  # The user have deleted the api_key element
  # This is a hook if dbm needs to synchronize
  def key_deleted(api_key)
    puts "***** Dbm::key_deleted()"
  end

  # If this is true the user can manually add and change api keys for this dbm
  def allow_manual_api_key?
    return true
  end

  # Returns the first enabled API key
  def first_enabled_key
    return self.api_keys.where(enabled: true).first
  end


  def has_configuration?(key)
    !get_configuration(key).nil?
  end

  def get_configuration(key)
    # throw configuration
    Rodash.get(configuration, key)
  end

  def name
    get_configuration("mock_name")
  end

  def name=(val)
    touch_configuration!
    configuration["mock_name"] = val
  end

  protected
  def touch_configuration!
    self.configuration = {} if not configuration.is_a?(Hash)
  end

end
