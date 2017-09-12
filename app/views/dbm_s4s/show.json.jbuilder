json.extract! @dbm_s4, :id, :user_id, :name, :db_plan, :endpoint
json.url dbm_s4_url(@dbm_s4, format: :json)
json.set! 'supported_repo_types', @dbm_s4.get_supported_repository_types
json.set! 'supported_db_plans', @dbm_s4.get_supported_db_plans
