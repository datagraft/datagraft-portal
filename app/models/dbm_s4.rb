class DbmS4 < Dbm

  def create_repository(rdf_repo, ep)
    puts "***** Enter DbmS4.create_repository(#{name})"

    begin
      ## TODO

      rdf_repo.repo_hash = {repo_id: "Dummy repo_id #{type}:#{name}:#{rdf_repo.name}" }
      rdf_repo.uri = "Dummy URI #{type}:#{name}:#{rdf_repo.name}"
      ep.repo_successfully_created
    rescue Exception => e
      se.error_occured_creating_repo
      puts 'Error creating S4 repository'
      puts e.message
      puts e.backtrace.inspect
    end

    puts "***** Exit DbmS4.create_repository()"
  end

  def upload_file_to_repository(rdf_repo, file, file_type)
    puts "***** Enter DbmS4.upload_file_to_repository(#{name})"
    puts rdf_repo.inspect
    puts file.inspect
    puts file_type.inspect
    puts "***** Exit DbmS4.upload_file_to_repository()"
  end

  def query_repository(db_repository, query_string)
  end

  def update_ontotext_repository_public(rdf_repo, public)
    puts "***** Enter DbmS4.update_ontotext_repository_public(#{name})"
    puts rdf_repo.inspect
    puts public
    puts "***** Exit DbmS4.update_ontotext_repository_public()"
  end

  def get_repository_size(rdf_repo)
    puts "***** Enter DbmS4.get_repository_size(#{name})"
    res = 42
    puts "***** Exit DbmS4.get_repository_size()"
    return res
  end

  def delete_repository(rdf_repo)
    puts "***** Enter DbmS4.delete_repository(#{name})"
      rdf_repo.repo_hash = {repo_id: 'deleted' }
      rdf_repo.uri = 'Deleted URI...'
    puts "***** Exit DbmS4.delete_repository()"
  end

  @@supported_repository_types = %w(RDF)
end
