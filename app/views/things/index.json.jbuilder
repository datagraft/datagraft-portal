
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
  json.array!(@things) do |thing|
    json.id thing.slug
    json.type thing.class.name
    json.set! 'dct:title', thing.name
    json.set! 'foaf:primaryTopic', thing_url(thing)
    json.set! '@type', 'dcat:catalogRecord'
    json.set! 'dcat:public', thing.public
    json.set! 'foaf:publisher', thing.user.username
    json.set! 'dct:modified', thing.updated_at
    json.set! 'dct:issued', thing.created_at
  end
end
