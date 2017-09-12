json.array!(@dbm_s4s) do |dbm|
  json.extract! dbm, :id, :user_id, :name, :db_plan, :endpoint
  json.url dbm_s4_url(dbm, format: :json)
  json.set! 'supported_repo_types', dbm.get_supported_repository_types
  json.set! 'supported_db_plans', dbm.get_supported_db_plans
end
