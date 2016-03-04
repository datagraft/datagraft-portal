module DataPagesHelper
  def data_pages_path(user = current_user)
    "/#{user.username}/data_pages" if user
  end

  def new_data_page_path
    "/#{current_user.username}/data_pages/new" if user_signed_in?
  end
end