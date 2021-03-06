# returns a default registry
prometheus = Prometheus::Client.registry

# initialisation: number of platform users (non-administrators)
begin
  num_platform_users = Prometheus::Client::Gauge.new(:num_platform_users, 'number of platform users')

  num_platform_users.set({}, User.where(:isadmin => false).count)
  prometheus.register(num_platform_users)
rescue => e  
  puts 'Error registering num_platform_users metric'
  puts e.message
  puts e.backtrace.inspect
end

# initialisation: number of assets and their versions
begin
  num_assets = Prometheus::Client::Gauge.new(:num_assets, 'number of assets - per user, public or private')
  num_forks = Prometheus::Client::Gauge.new(:num_forks, 'number of forks of assets - per asset type')
  things = Thing.includes(:user).where.not("name LIKE ?", "%previewed_dataset_%")
  things.each do |thing|
    # public/private assets of a type for the user
    number = num_assets.get({asset_type: thing.type, owner: thing.user.username, access_permission: thing.public ? 'public' : 'private'}) ? num_assets.get({asset_type: thing.type, owner: thing.user.username, access_permission: thing.public ? 'public' : 'private'}) : 0

    num_assets.set({asset_type: thing.type, owner: thing.user.username, access_permission: thing.public ? 'public' : 'private'}, number + 1)

    number = num_forks.get({asset_type: thing.type}) ? num_forks.get({asset_type: thing.type}) : 0
    num_forks.set({asset_type: thing.type}, thing.parent ? number + 1 : number)
  end

  prometheus.register(num_assets)
  prometheus.register(num_forks)
rescue => e
  puts 'Error registering num_assets metric'
  puts e.message
  puts e.backtrace.inspect
end

num_query_executions = Prometheus::Client::Counter.new(:num_query_executions, 'number of query executions')
prometheus.register(num_query_executions)

num_platform_users = Prometheus::Client.registry.get(:num_platform_users)
num_assets = Prometheus::Client.registry.get(:num_assets)
num_forks = Prometheus::Client.registry.get(:num_forks)
num_query_executions = Prometheus::Client.registry.get(:num_query_executions)
