json.array!(@dbm_s4s) do |dbm|
  json.extract! dbm, :id, :user_id, :name
  json.set! 'supported_repo_types', dbm.get_supported_repository_types
end
json.array!(@dbm_ontotext_legs) do |dbm|
  json.extract! dbm, :id, :user_id, :name
  json.set! 'supported_repo_types', dbm.get_supported_repository_types
end
json.array!(@dbm_arangos) do |dbm|
  json.extract! dbm, :id, :user_id, :name
  json.set! 'supported_repo_types', dbm.get_supported_repository_types
end
