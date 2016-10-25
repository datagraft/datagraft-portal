module ThingConcern
  extend ActiveSupport::Concern

  def virtual_resource_name(underscore = false)
    name = /^(.+)Controller$/.match(self.class.name)[1].singularize
    underscore ? name.underscore : name 
  end

  def virtual_resources_name
    /^\/[^\/]*\/([^\/]+)/.match(request.env['PATH_INFO'])[1]
    # throw  /^\/[^\/]*\/([^\/]+)/.match(request.env['PATH_INFO'])
    # throw self.class.name.underscore
    # /^(.+)_controller$/.match(self.class.name.underscore)[1]
  end

  def virtual_resource
    Object.const_get(virtual_resource_name)
  end

  def set_thing
    throw "A username parameter is required" if not params[:username]
    if user_signed_in? && (current_user.username == params[:username] || params[:username] == 'myassets')
      user = current_user
    else
      raise CanCan::AccessDenied.new("Not authorized!") if params[:username] == 'myassets'
      user = User.find_by_username(params[:username]) or not_found
    end
    @thing = user.send(virtual_resources_name).friendly.find(params[:id])

    if params[:version_at]
      @latest_thing = @thing
      @thing = @thing.version_at(params[:version_at]) or not_found
    end

    instance_variable_set("@"+virtual_resource_name(true), @thing)
  end
end