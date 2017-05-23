
json.query do
  json.name @query.name
  json.query_string @query.query_string
  json.language @query.language
end

json.queriable_data_store do
  json.name @queriable_data_store.name
  json.uri @queriable_data_store.uri
  json.hosting_provider @queriable_data_store.hosting_provider
end
