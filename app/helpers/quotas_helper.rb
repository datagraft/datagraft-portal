module QuotasHelper

  # Find how many files the user has in db
  def quota_used_file_count(user)
    return Filestore.where(:user => user).where.not("name LIKE ?", "%previewed_dataset_%").count
  end

  # Find users files and calculate total number of bytes
  def quota_used_file_size(user)
    total_file_size = 0;
    users_files = Filestore.where(:user => user).where.not("name LIKE ?", "%previewed_dataset_%")
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

  # Find how many sparql endpoints the user has or a dbm has
  def quota_used_sparql_count_dbm(dbm = nil)
    if dbm == nil
      res = 0
    else
      res = dbm.used_sparql_count
    end
    return res
  end

  # Find users sparql endpoints and calculate total number of triples
  def quota_used_sparql_triples_dbm(dbm=nil)
    total_repo_sparql_triples = 0
    total_cached_sparql_triples = 0
    cached_sparql_requests = 0

    if dbm == nil
      ret = {repo_triples: total_repo_sparql_triples, cached_triples: total_cached_sparql_triples, cached_req: cached_sparql_requests}
    else
      ret = dbm.used_sparql_triples
    end
    puts 'Ret:'+ret.to_s
    return ret
  end

  # Check if it is room for another sparql endpoint in dbm
  def quota_dbm_room_for_new_sparql_count?(dbm)
    ret_ok = false
    unless dbm == nil  #Check for specific dbm
      current_count = dbm.used_sparql_count
      limit_count = dbm.quota_sparql_count
      ret_ok = current_count < limit_count
    end
    return ret_ok
  end

  # Check if the user can create another sparql endpoint
  def quota_user_room_for_new_sparql_count?(user)
    ret_ok = false
    unless user == nil #Check for room in any dbm
      dbm_list = user.search_for_existing_dbms_reptype('RDF')
      res = []
      dbm_list.each do |dbm|
        ret_ok = true if quota_dbm_room_for_new_sparql_count?(dbm)
      end
    end

    unless ret_ok
      flash[:error] = "Your SPARQL endpoint count quota is exceeded"
    end

    return ret_ok
  end

  # Filter out the Dbms without room for another sparql endpoint
  def quota_filter_dbm_sparql_count?(dbm_list)
    res = []
    dbm_list.each do |dbm|
      res << dbm if quota_dbm_room_for_new_sparql_count?(dbm)
    end
    return res
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
