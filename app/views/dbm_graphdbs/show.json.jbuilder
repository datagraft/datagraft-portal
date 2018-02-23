json.extract! @dbm_graphdb, :id, :user_id, :name, :db_plan, :endpoint
json.url dbm_graphdb_url(@dbm_graphdb, format: :json)
json.set! 'supported_repo_types', @dbm_graphdb.get_supported_repository_types
json.set! 'supported_db_plans', @dbm_grapdb.get_supported_db_plans
