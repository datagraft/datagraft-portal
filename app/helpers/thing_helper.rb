module ThingHelper
  def thing_url(thing, parameters = {})
    return root_url[0...-1] + thing_path(thing, parameters)
  end

  def thing_path(thing, parameters = {})
    thing_generic_path(thing, '', parameters)
  end

  def thing_edit_path(thing, parameters = {})
    thing_generic_path(thing, '/edit', parameters)
  end

  def thing_star_path(thing, parameters = {})
    thing_generic_path(thing, '/star', parameters)
  end

  def thing_unstar_path(thing, parameters = {})
    thing_generic_path(thing, '/unstar', parameters)
  end

  def thing_metadata_path(thing, parameters = {})
    thing_generic_path(thing, '/metadata', parameters)
  end

  def thing_versions_path(thing, parameters = {})
    thing_generic_path(thing, '/versions', parameters)
  end

  def thing_version_fork_path(thing)
    if thing.paper_trail.live?
      thing_fork_path(@thing)
    else
      thing_fork_path(@thing, { version_at: @thing.updated_at+1})
    end
  end

  def thing_fork_path(thing, parameters = {})
    thing_generic_path(thing, '/fork', parameters)
  end

  def things_path(thing, parameters = {})
    classname = thing.class.name
    username = thing.user.nil? ? 'myassets' : thing.user.username
    "/#{username}/#{classname.underscore.pluralize}#{ "?#{parameters.to_query}" if parameters.present? }"
  end

  def new_generic_thing_path
    return if not user_signed_in?
    username = current_user.username
    "/#{username}/#{params[:controller]}/new"
  end


  def update_asset_version_metric(asset_type_string)
    begin
      num_assets = 0
      case asset_type_string
      when "DataPage"
        Thing.includes(:versions).where(type: "DataPage").each do |thing|
          num_assets += thing.versions.count
        end
      when "Transformation"
        Thing.includes(:versions).where(type: "Transformation").each do |thing|
          num_assets += thing.versions.count
        end
      when "Query"
        Thing.includes(:versions).where(type: "Query").each do |thing|
          num_assets += thing.versions.count
        end
      when "SparqlEndpoint"
        Thing.includes(:versions).where(type: "SparqlEndpoint").each do |thing|
          num_assets += thing.versions.count
        end
      when "ArangoDb"
        Thing.includes(:versions).where(type: "ArangoDb").each do |thing|
          num_assets += thing.versions.count
        end
      when "Filestore"
        Thing.includes(:versions).where(type: "Filestore").each do |thing|
          num_assets += thing.versions.count
        end
      when "DataDistribution"
        Thing.includes(:versions).where(type: "DataDistribution").each do |thing|
          num_assets += thing.versions.count
        end
      else
        throw "unknown asset type"
      end
      num_versions = Prometheus::Client.registry.get(:num_versions)
      num_versions.set({asset_type: asset_type_string}, num_assets)
    rescue => e
      puts 'Error updating num_versions metric: '
      puts e.message
      puts e.backtrace
    end
  end

  def reset_num_assets_public_private(thing)
    # Get the num_assets metric
    num_assets = Prometheus::Client.registry.get(:num_assets)

    # Get the number of public and private things of this type for the owner of the asset
    if thing.type === 'Filestore' then
      # Exclude previewed filestores
      number_public_things = Thing.where(:user => thing.user, :type => thing.type, :public => true).where.not("name LIKE ?", "%previewed_dataset_%").count
      number_private_things = Thing.where(:user => thing.user, :type => thing.type, :public => false).where.not("name LIKE ?", "%previewed_dataset_%").count
    else
      number_public_things = Thing.where(:user => thing.user, :type => thing.type, :public => true).count
      number_private_things = Thing.where(:user => thing.user, :type => thing.type, :public => false).count
    end

    # Set the number of public and private things of this type for the owner
    if !num_assets.nil?
      num_assets.set({asset_type: thing.type, owner: thing.user.username, access_permission: 'public'}, number_public_things)
      num_assets.set({asset_type: thing.type, owner: thing.user.username, access_permission: 'private'}, number_private_things)
    end
  end

  def reset_num_assets(thing, change)
    begin
      # Get the num_assets metric
      num_assets = Prometheus::Client.registry.get(:num_assets)

      # Null-safely initialised change of the metric number; should be negative if we destroy metric (unfortunately necessary because when deleting an asset we can only call this method immediately before destroying the thing [otherwise it gets destroyed and there is no reference to it to pass to this function])
      change ||= 0

      if thing.type === 'Filestore' then
        # Exclude previewed filestores
        number_things = Thing.where(:user => thing.user, :type => thing.type, :public => thing.public).where.not("name LIKE ?", "%previewed_dataset_%").count
      else
        number_things = Thing.where(:user => thing.user, :type => thing.type, :public => thing.public).count
      end

      num_assets.set({asset_type: thing.type, owner: thing.user.username, access_permission: thing.public ? 'public' : 'private'}, number_things + change)



      #      # Set the metric for number of Transformations
      #      number_public_transformations = Thing.where(:user => user, :type => 'Transformation', :public => true).count
      #      number_private_transformations = Thing.where(:user => user, :type => 'Transformation', :public => false).count
      #      num_assets.set({asset_type: 'Transformation', owner: user.username, access_permission: true}, number_public_transformations)
      #      num_assets.set({asset_type: 'Transformation', owner: user.username, access_permission: false}, number_private_transformations)
      #
      #      # Set the metric for number of Queries
      #      number_public_queries = Thing.where(:user => user, :type => 'Query', :public => true).count
      #      number_private_queries = Thing.where(:user => user, :type => 'Query', :public => false).count
      #      num_assets.set({asset_type: 'Query', owner: user.username, access_permission: true}, number_public_queries)
      #      num_assets.set({asset_type: 'Query', owner: user.username, access_permission: false}, number_private_queries)
      #
      #      # Set the metric for number of SPARQL endpoints
      #      number_public_sparql_endpoints = Thing.where(:user => user, :type => 'SparqlEndpoint', :public => true).count
      #      number_private_sparql_endpoints = Thing.where(:user => user, :type => 'SparqlEndpoint', :public => false).count
      #      num_assets.set({asset_type: 'SparqlEndpoint', owner: user.username, access_permission: true}, number_public_sparql_endpoints)
      #      num_assets.set({asset_type: 'SparqlEndpoint', owner: user.username, access_permission: false}, number_private_sparql_endpoints)
      #
      #      # Set the metric for number of Filestores
      #      number_public_filestores = Thing.where(:user => user, :type => 'Filestore', :public => true).where.not("name LIKE ?", "%previewed_dataset_%").count
      #      number_private_filestores = Thing.where(:user => user, :type => 'Filestore', :public => false).where.not("name LIKE ?", "%previewed_dataset_%").count
      #      num_assets.set({asset_type: 'Filestore', owner: user.username, access_permission: true}, number_public_filestores)
      #      num_assets.set({asset_type: 'Filestore', owner: user.username, access_permission: false}, number_private_filestores)
    rescue => e
      puts 'Error setting num_assets metric'
      puts e.message
      puts e.backtrace.inspect
    end
  end

  def increment_forks_metric(thing)
    begin
      num_forks = Prometheus::Client.registry.get(:num_forks)
      curr_num_forks = num_forks.get({asset_type: self.type})

      curr_num_forks = 0 if !curr_num_forks
      num_forks.set({asset_type: self.type}, curr_num_forks + 1)
    rescue => e
      puts 'Error decrementing num_forks metric'
      puts e.message
      puts e.backtrace.inspect
    end
  end

  # should we call this at all?
  def decrement_forks_metric(thing)
    num_forks = Prometheus::Client.registry.get(:num_forks)
    curr_num_forks = num_forks.get({asset_type: self.type})
    num_forks.set({asset_type: self.type}, curr_num_forks - 1)
  end

  def increment_query_execution_metric(query)
    num_query_executions = Prometheus::Client.registry.get(:num_query_executions)
    if(!query.slug)
      num_query_executions.increment({ query_slug: 'Sparql / Arango querying panel', query_type: 'unknown' })
    else
      num_query_executions.increment({ query_slug: query.slug, query_type: query.query_type })
    end

  end
  private

  def thing_generic_path(thing, method, parameters = {})
    user = thing.nil? ? current_user : thing.user
    return "" if user.nil?

    classname = thing.class.name

    slug = (thing.nil? || thing.new_record?) ? '' : thing.slug

    "/#{user.username}/#{classname.underscore.pluralize}/#{slug}#{method}#{ "?#{parameters.to_query}" if parameters.present? }"
  end

  def thing_icon_name(thing)
    ret = "help"
    thing_type = thing.class.model_name.param_key
    if thing_type == "data_page"
      ret = "icon--data_page.svg"
    elsif thing_type == "filestore"
      ret = "icon--data_page.svg"
    elsif thing_type == "query"
      ret = "icon--query.svg"
    elsif thing_type == "transformation"
      ret = "icon--transformation.svg"
    elsif thing_type == "data_store"
      ret = "icon--queriable_data_store.svg"
    elsif thing_type == "sparql_endpoint"
      ret = "icon--queriable_data_store.svg"
    elsif thing_type == "arango_db"
      ret = "icon--queriable_data_store.svg"
    end
    return ret
  end

end
