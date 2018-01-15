json.array!(@api_keys) do |api_key|
  json.extract! api_key, :id, :user_id, :dbm_id, :enabled, :name, :key_pub, :key_secret
  json.url dbm_api_key_url(api_key.dbm, api_key, format: :json)
end
