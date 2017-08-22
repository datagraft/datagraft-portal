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
    puts "***** Enter DbmS4.query_repository(#{name})"
    puts query_string
    res = {"head" => {"vars" => ["s", "p", "o"]}, "results" => {"bindings"=>[{"p"=>{"type"=>"uri", "value"=>"p-dummy"}, "s"=>{"type"=>"uri", "value"=>"s-dummy"}, "o"=>{"type"=>"uri", "value"=>"o-dummy"}}]}}
    puts "***** Exit DbmS4.query_repository()"
    return res
  end

  def update_ontotext_repository_public(rdf_repo, public)
    puts "***** Enter DbmS4.update_ontotext_repository_public(#{name})"
    puts rdf_repo.inspect
    puts public
    puts "***** Exit DbmS4.update_ontotext_repository_public()"
  end

  def used_sparql_count
    rdf_repo_list = self.rdf_repos.all
    return rdf_repo_list.size
  end

  def used_sparql_triples
    puts "***** Enter DbmS4.quota_used_sparql_triples(#{name})"
    total_repo_sparql_triples = 0
    total_cached_sparql_triples = 0
    cached_sparql_requests = 0

    rdf_repo_list = self.rdf_repos.all
    rdf_repo_list.each do |rr|
      total_repo_sparql_triples += rr.get_repository_size
    end
    res = {repo_triples: total_repo_sparql_triples, cached_triples: total_cached_sparql_triples, cached_req: cached_sparql_requests}
    puts "***** Exit DbmS4.quota_used_sparql_triples()"
    return res
  end

  def get_repository_size(rdf_repo)
    puts "***** Enter DbmS4.get_repository_size(#{name})"
    res = 100*rdf_repo.id
    puts "***** Exit DbmS4.get_repository_size()"
    return res
  end

  def quota_sparql_count()
    puts "***** Enter DbmS4.quota_sparql_count(#{name})"
    res = id
    puts "***** Exit DbmS4.quota_sparql_count()"
    return res
  end

  def quota_sparql_ktriples()
    puts "***** Enter DbmS4.quota_sparql_ktriples(#{name})"
    res = id
    puts "***** Exit DbmS4.quota_sparql_ktriples()"
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
