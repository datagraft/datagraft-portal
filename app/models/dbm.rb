class Dbm < ApplicationRecord
  before_destroy :unreg_before_destroy  # This is important to have available ApiKeys when deleting the repos

  belongs_to :user
  has_many :dbm_accounts, dependent: :destroy
  has_many :api_keys, dependent: :destroy
  has_many :rdf_repos, dependent: :destroy
  has_many :things, dependent: :destroy

  cattr_accessor :supported_repository_types


  def find_tings
    return []
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
    api_key = self.api_keys.where(enabled: true).first

    raise "No enabled API key found" if api_key.nil?

    return api_key
  end

  # Create and add new DbmAccount to the DBM
  def add_account(name, password, enabled = true)
    self.save
    da = self.dbm_accounts.create()

    da.name = name
    da.encrypted_password = password   #TODO
    da.enabled = enabled
    da.user = user
    da.save

    self.save
    return da
  end


  # Delete DbmAccount from the DBM
  def delete_account(dbm_account)
    self.api_keys.find(dbm_account).destroy
  end








  def has_configuration?(key)
    !get_configuration(key).nil?
  end

  def get_configuration(key)
    # throw configuration
    Rodash.get(configuration, key)
  end

  def name
    res = get_configuration("name")
    res = get_configuration("mock_name") if res == nil
    return res
  end

  def name=(val)
    touch_configuration!
    configuration["name"] = val
  end

  protected
  def touch_configuration!
    self.configuration = {} if not configuration.is_a?(Hash)
  end

  private
  def unreg_before_destroy()
    puts "***** Enter Dbm.unreg_before_destroy(#{name})"
    puts "***** Exit Dbm.unreg_before_destroy()"
  end

end
