module UserHelper
  def user_path(user)
    "/"+user.username
  end
end