class RdfRepo < ApplicationRecord
  belongs_to :dbm
  has_many :things

  def create_repository(ep)
    puts "***** Enter RdfRepo.create_repository(#{name})"
    dbm.create_repository(self, ep)
    puts repo_hash
    puts "***** Exit RdfRepo.create_repository()"
  end

  def upload_file_to_repository(file, file_type)
    puts "***** Enter RdfRepo.upload_file_to_repository(#{name})"
    dbm.upload_file_to_repository(self, file, file_type)
    puts "***** Exit RdfRepo.upload_file_to_repository()"
  end

  def query_repository(query_string)
    puts "***** Enter RdfRepo.query_repository(#{name})"
    res = dbm.query_repository(self, query_string)
    puts "***** Exit RdfRepo.query_repository()"
    return res
  end

  def update_ontotext_repository_public(public)
    puts "***** Enter RdfRepo.update_ontotext_repository_public(#{name})"
    dbm.update_ontotext_repository_public(self, public)
    puts "***** Exit RdfRepo.update_ontotext_repository_public()"
  end

  def get_repository_size()
    puts "***** Enter RdfRepo.get_repository_size(#{name})"
    res = dbm.get_repository_size(self)

    # TODO fix cached size
    #ep.cached_size = resp_size.body ||= ep.cached_size
    #ep.save
    puts "***** Exit RdfRepo.get_repository_size()"
    return res
  end

  def delete_repository()
    puts "***** Enter RdfRepo.delete_repository(#{name})"
    dbm.delete_repository(self)
    puts "***** Exit RdfRepo.delete_repository()"
  end


  def has_configuration?(key)
    !get_configuration(key).nil?
  end

  def get_configuration(key)
    # throw configuration
    Rodash.get(configuration, key)
  end

  def repo_hash
    get_configuration("repo_hash")
  end

  def repo_hash=(val)
    touch_configuration!
    self.configuration["repo_hash"] = val
  end

  def uri
    get_configuration("uri")
  end

  def uri=(val)
    touch_configuration!
    self.configuration["uri"] = val
  end

  def name
    get_configuration("name")
  end

  def name=(val)
    touch_configuration!
    self.configuration["name"] = val
  end

  protected
  def touch_configuration!
    self.configuration = {} if not configuration.is_a?(Hash)
  end

end
