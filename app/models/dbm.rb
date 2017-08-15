class Dbm < ApplicationRecord
  has_many :dbm_account, dependent: :destroy
  has_many :api_key, dependent: :destroy
  has_many :rdf_repo, dependent: :destroy


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

end
