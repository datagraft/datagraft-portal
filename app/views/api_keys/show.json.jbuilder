json.extract! @api_key, :key_pub, :key_secret, :name, :enabled
json.url dbm_api_key_url(@api_key.dbm, @api_key, format: :json) 
