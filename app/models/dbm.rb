class Dbm < ApplicationRecord
  has_many :dbm_account, dependent: :destroy
  has_many :dbm_key, dependent: :destroy
  has_many :rdf_repo, dependent: :destroy
end
