class DbAccount < ApplicationRecord
  belongs_to :user
  has_many :db_keys, dependent: :destroy
  has_many :things, dependent: :destroy

  def delete()
  end

  def new_repository(thing)
  end

  def upload_file_to_repository(db_repository, file, file_type)
  end

  def query_repository(repo_hash, query_string)
  end

  def delete_repository(repo_hash)
  end

  def add_key(key, name)
  end

  def generate_key(db_key)
  end

  def delete_key(db_key)
  end

  def update_key(db_key)
  end

  protected
  def touch_configuration!
    self.configuration = {} if not configuration.is_a?(Hash)
  end

end
