module QueriableDataStoresHelper
  def new_queriable_data_store_path(parameters = {})
    return "/"+current_user.username+"/queriable_data_stores/new#{ "?#{parameters.to_query}" if parameters.present? }"
  end
end
