json.set! "@id", request.original_url
json.set! "@type", "dcat:Catalog"
json.set! "@context" do
  json.dcat 'http://www.w3.org/ns/dcat#'
  json.foaf 'http://xmlns.com/foaf/0.1/'
  json.dct 'http://purl.org/dc/terms/'
  json.xsd 'http://www.w3.org/2001/XMLSchema#'
  
  json.set! 'dct:issued' do
    json.set! '@type', 'xsd:date'
  end

  json.set! 'dct:modified' do
    json.set! '@type', 'xsd:date'
  end

  json.set! 'foaf:primaryTopic' do
    json.set! '@type', '@id'
  end

  json.set! 'dcat:distribution' do
    json.set! '@type', '@id'
  end
end

json.set! 'dcat:record' do
  json.array!(@queriable_data_stores) do |queriable_data_store|
    # json.set! 'foaf:primaryTopic', thing_url(transformation, format: :json)
    json.id queriable_data_store.slug
    json.type 'queriable_data_store'
    json.set! 'dct:title', queriable_data_store.name
    json.set! 'foaf:primaryTopic', thing_url(queriable_data_store)
    json.set! '@type', 'dcat:catalogRecord'
    json.set! 'dcat:public', queriable_data_store.public
    json.set! 'foaf:publisher', queriable_data_store.user.username
    json.set! 'dct:modified', queriable_data_store.updated_at
    json.set! 'dct:issued', queriable_data_store.created_at
    json.set! 'dcat:accessURL', queriable_data_store.uri
  end
end