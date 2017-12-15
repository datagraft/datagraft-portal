json.array!(@dbm_accounts) do |dbm_account|
  json.extract! dbm_account, :id, :user_id, :dbm_id, :enabled, :name, :public
  json.url dbm_dbm_account_url(dbm_account.dbm, dbm_account, format: :json)
end
