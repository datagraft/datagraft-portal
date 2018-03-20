json.extract! @dbm_arango, :id, :user_id, :name, :uri
json.url dbm_arango_url(@dbm_arango, format: :json)
json.set! 'supported_repo_types', @dbm_arango.get_supported_repository_types
