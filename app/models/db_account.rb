class DbAccount < ApplicationRecord
  belongs_to :user
  has_many :db_keys, dependent: :destroy

  def delete()
  end

  def new_repo()
  end

  def upload_file_to_repo(repo_hash, file)
  end

  def query_repo(repo_hash, query_string)
  end

  def delete_repo(repo_hash)
  end

  def add_key(key, name)
end