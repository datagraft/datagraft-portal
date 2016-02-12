
json.set! "@id", request.protocol+request.host_with_port+thing_path(@queriable_data_store)

json.set! "@context" do 
  json.dcat 'http://www.w3.org/ns/dcat#'
  json.dct 'http://purl.org/dc/terms/'
end

json.set! 'dct:title', @queriable_data_store.name
json.set! 'dct:issued', @queriable_data_store.created_at
json.set! 'dct:modified', @queriable_data_store.updated_at