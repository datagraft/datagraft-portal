class RdfRepo < ApplicationRecord
  belongs_to :dbm
  has_many :things

  def create_repository()
  end

  def upload_file_to_repository(db_repository, file, file_type)
  end

  def query_repository(db_repository, query_string)
  end

  def get_repository_size(db_repository)
  end

  def delete_repository(db_repository)
  end

end
