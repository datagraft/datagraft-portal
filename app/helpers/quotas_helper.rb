module QuotasHelper
  include SparqlEndpointsHelper

  # Find how many files the user has in db
  def quota_used_file_count(user)
    return user.filestores.count
  end

  # Find users files and calculate total number of bytes
  def quota_used_file_size(user)
    total_file_size = 0;
    users_files = user.filestores
    users_files.each do |fs|
      unless fs.file == nil
        unless fs.file_size == nil
          total_file_size += fs.file_size
        else
          puts "Filestore is missing size information:"+fs.inspect
        end
      else
        puts "Filestore is missing file object:"+fs.inspect
      end
    end
    return total_file_size
  end

  # Check if the user can upload another file
  def quota_room_for_new_file_count?(user)
    current_count = quota_used_file_count(user)
    limit_count = user.quota_filestore_count
    ret_ok = current_count < limit_count

    unless ret_ok
      flash[:error] = "Your file count quota is exceeded"
    end

    return ret_ok
  end

  # Check if the user has room for another "file_size" bytes
  def quota_room_for_new_file_size?(user, file_size)
    current_size = quota_used_file_size(user)
    limit_size = user.quota_filestore_ksize*1024
    ret_ok = (current_size+file_size) < limit_size

    unless ret_ok
      flash[:error] = "Your file size quota is exceeded"
    end

    return ret_ok
  end

  # Find how many sparql endpoints the user has
  def quota_used_sparql_count(user)
    return user.sparql_endpoints.count
  end

  # Find users sparql endpoints and calculate total number of triples
  def quota_used_sparql_triples(user)
    total_sparql_triples = 0;
    users_sparql = user.sparql_endpoints
    users_sparql.each do |se|
      size = repository_size_param(user, se)
      puts 'Quota triples:'+size
      unless size == nil
        total_sparql_triples += size.to_i
      else
        puts "Sparql_endpoint is missing size information:"+se.inspect
      end
    end
    puts 'Quota triples sum:'+total_sparql_triples.to_s
    return total_sparql_triples
  end

  # Check if the user can create another sparql endpoint
  def quota_room_for_new_sparql_count?(user)
    current_count = quota_used_sparql_count(user)
    limit_count = user.quota_sparql_count
    ret_ok = current_count < limit_count

    unless ret_ok
      flash[:error] = "Your SPARQL endpoint count quota is exceeded"
    end

    return ret_ok
  end


  # Find how many transformations the user has
  def quota_used_transformations_count(user)
    return user.transformations.count
  end

  # Check if the user can create another transformation
  def quota_room_for_new_transformations_count?(user)
    current_count = quota_used_transformations_count(user)
    limit_count = user.quota_transformation_count
    ret_ok = current_count < limit_count

    unless ret_ok
      flash[:error] = "Your transformation count quota is exceeded"
    end

    return ret_ok
  end

end
