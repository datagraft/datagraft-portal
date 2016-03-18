json.set! "@id", request.protocol+request.host_with_port+thing_path(@thing)

json.set! "@context" do 
  json.dcat 'http://www.w3.org/ns/dcat#'
  json.dct 'http://purl.org/dc/terms/'
end

json.id @thing.slug
json.set! 'foaf:publisher', @thing.user.username
json.set! 'dcat:public', @thing.public
json.set! 'dct:title', @thing.name
json.set! 'dct:description', @thing.description
json.set! 'dct:issued', @thing.created_at
json.set! 'dct:modified', @thing.updated_at


