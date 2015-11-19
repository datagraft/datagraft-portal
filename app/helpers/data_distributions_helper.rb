module DataDistributionsHelper
  def new_data_distribution_path
    "/publish"
  end
  def data_distribution_path(data_distribution_input)
    "/#{data_distribution_input.user.username}/data_distributions/#{data_distribution_input.slug}"
  end
  def data_distributions_path(post=false)
    return "/"+current_user.username+"/data_distributions" if post
    return "/explore" unless user_signed_in?
    
    return "/#{current_user.username}/data_distributions"
  end
  
end
