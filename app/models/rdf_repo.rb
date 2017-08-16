class RdfRepo < ApplicationRecord
  belongs_to :dbm
  has_many :things

  def create_repository(dbm)
  end

  def upload_file_to_repository(file, file_type)
  end

  def query_repository(query_string)
  end

  def get_repository_size()
  end

  def delete_repository()
  end

end
