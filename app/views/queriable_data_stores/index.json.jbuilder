json.array!(@queriable_data_stores) do |queriable_data_store|
  json.extract! queriable_data_store, :id
  json.url thing_url(queriable_data_store)
end
