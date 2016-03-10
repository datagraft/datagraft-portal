module QueriesHelper
  def queries_path
    return "/explore" unless user_signed_in?
    return "/#{current_user.username}/queries"
  end
end