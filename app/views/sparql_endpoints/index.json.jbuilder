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
  json.array!(@sparql_endpoints) do |sparql_endpoint|
    json.id sparql_endpoint.slug
    json.id_num sparql_endpoint.id
    json.type 'sparql_endpoint'
    json.set! 'dct:title', sparql_endpoint.name
    json.set! 'foaf:primaryTopic', thing_url(sparql_endpoint)
    json.set! '@type', 'dcat:catalogRecord'
    json.set! 'dcat:public', sparql_endpoint.public
    json.set! 'foaf:publisher', sparql_endpoint.user.username
    json.set! 'dct:modified', sparql_endpoint.updated_at
    json.set! 'dct:issued', sparql_endpoint.created_at
    json.set! 'dcat:accessURL', sparql_endpoint.uri
  end
end
