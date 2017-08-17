class Dbm < ApplicationRecord
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

  def add_key(key, name)
  end

  def delete_key(api_key)
  end

  def update_key(api_key)
  end


  def has_configuration?(key)
    !get_configuration(key).nil?
  end

  def get_configuration(key)
    # throw configuration
    Rodash.get(configuration, key)
  end

  def user
    return dbm_accounts.first.user
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
