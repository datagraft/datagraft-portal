
json.set! "@id", request.protocol+request.host_with_port+thing_path(@filestore)

json.set! "@context" do
  json.dcat 'http://www.w3.org/ns/dcat#'
  json.dct 'http://purl.org/dc/terms/'
end

json.id @thing.slug

json.set! 'dct:title', @filestore.name
json.set! 'dct:issued', @filestore.created_at
json.set! 'dct:modified', @filestore.updated_at

json.set! 'dcat:accessURL', request.protocol+request.host_with_port+filestore_attachment_path(@thing) if @filestore.file
json.set! 'dcat:mediaType', @filestore.file_content_type
json.set! 'dcat:byteSize', @filestore.file_size

json.set! 'sin:extension', Rack::Mime::MIME_TYPES.invert[@filestore.file_content_type].to_s[1..-1]
