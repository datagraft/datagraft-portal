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

  @@supported_repository_types = %w(BASE)
end
