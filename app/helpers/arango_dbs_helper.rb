module ArangoDbsHelper

  def new_arango_db_path(parameters = {})
    return "/"+current_user.username+"/arango_dbs/new#{ "?#{parameters.to_query}" if parameters.present? }"
  end

  def new_arango_db_collection_path(parameters = {})
    return "/"+current_user.username+"/arango_dbs/#{@thing.id}/collection/new#{ "?#{parameters.to_query}" if parameters.present? }"
  end

  def create_arango_db_collection_path(parameters = {})
    return "/"+current_user.username+"/arango_dbs/#{@thing.id}/collection#{ "?#{parameters.to_query}" if parameters.present? }"
  end

  def publish_arango_db_collection_path(collection_name, parameters = {})
    return "/"+current_user.username+"/arango_dbs/#{@thing.id}/collection/#{collection_name}/publish#{ "?#{parameters.to_query}" if parameters.present? }"
  end

  def arango_db_collection_path(collection_name, parameters = {})
    return "/"+current_user.username+"/arango_dbs/#{@thing.id}/collection/#{collection_name}#{ "?#{parameters.to_query}" if parameters.present? }"
  end


  ## Return all queries
  #def all_queries
  #  return Thing.where(type: 'Query')
  #end


  # Search for queries
  def search_for_existing_aql_queries
    res = []
    user = @thing.user
    tmp_user = user.queries.includes(:user).where(public: false)
    tmp_pub = Thing.public_list.includes(:user).where(:type => ['Query'])
    tmp_all = tmp_user + tmp_pub

    tmp_all.each do |q|
      qt = q.query_type
      if (qt == "AQL")
        res << q
      end
    end

    return res
  end


  # Check if query links to arango database
  def query_links_to_arango_db(query, adb)
    return ArangoDbQuery.exists?({query_id: query.id, arango_db_id: adb.id})
  end

end
