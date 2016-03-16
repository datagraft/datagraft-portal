module UtilityFunctionsHelper
  def new_utility_function_path
    "/#{current_user.username}/utility_functions/new" if user_signed_in?
  end
end
