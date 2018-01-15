json.set! 'dbm_arangos' do
  json.array!(@dbm_arangos) do |dbm|
    json.extract! dbm, :id, :user_id, :name, :uri
    json.url dbm_arango_url(dbm, format: :json)
    json.set! 'supported_repo_types', dbm.get_supported_repository_types
  end
end
json.set! 'db_entries' do
  json.array!(@db_entries) do |entry|
    json.extract! entry, :description, :entry
  end
end
