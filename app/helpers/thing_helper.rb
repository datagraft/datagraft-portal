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
      when "QueriableDataStore"
        Thing.includes(:versions).where(type: "QueriableDataStore").each do |thing|
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
    rescue Exception => e
      puts 'Error updating num_versions metric: '
      puts e.message  
      puts e.backtrace
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
end
