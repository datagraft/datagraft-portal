json.extract! @dbm_account, :name, :enabled
json.url dbm_dbm_account_url(@dbm_account.dbm, @dbm_account, format: :json)
