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
  def add_key(name, key_secret)
    self.save
    api_key = self.api_keys.create()

    api_key.name = name
    api_key.key = key_secret
    api_key.enabled = true
    api_key.save

    self.save
    return api_key
  end


  # Delete API key from the DBM
  def delete_key(api_key)
    self.api_keys.find(api_key).destroy
  end


  # TO-BE-DELETED. NOT NEEDED!
  def update_key(api_key)
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
