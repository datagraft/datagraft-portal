json.set! "@id", request.protocol+request.host_with_port+thing_path(@transformation)

json.set! "@context" do 
  json.dcat 'http://www.w3.org/ns/dcat#'
  json.dct 'http://purl.org/dc/terms/'
end

json.id @transformation.slug
json.set! 'foaf:publisher', @transformation.user.username
json.set! 'dcat:public', @transformation.public
json.set! 'dct:title', @transformation.name
json.set! 'dct:description', @transformation.description
json.set! 'dct:issued', @transformation.created_at
json.set! 'dct:modified', @transformation.updated_at


