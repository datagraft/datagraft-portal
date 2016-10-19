module FilestoresHelper
  def new_filestore_path
    "/publishfilestore"
  end
  def filestore_preview_path(filestore_input)
    "#{filestore_path(filestore_input)}/preview"
  end
  
  def filestore_path(filestore_input)
    "/#{filestore_input.user.username}/filestores/#{filestore_input.slug}"
  end
  def filestores_path(post=false)
    return "/"+current_user.username+"/filestores" if post
    return "/explore" unless user_signed_in?

    return "/#{current_user.username}/filestores"
  end

  SEPARATOR_LIST = %w(COMMA SEMI TAB)
  def get_separator_list
    return SEPARATOR_LIST
  end

end
