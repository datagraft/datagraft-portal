module UserHelper
  def user_path(user)
    "/"+user.username
  end
  
  def reset_num_users_metric
    num_platform_users = Prometheus::Client.registry.get(:num_platform_users)
    num_platform_users.set(User.where(:isadmin => false).count, labels: {})
  end
end