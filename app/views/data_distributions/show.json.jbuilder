
json.set! "@id", request.protocol+request.host_with_port+thing_path(@data_distribution)

json.set! "@context" do 
  json.dcat 'http://www.w3.org/ns/dcat#'
  json.dct 'http://purl.org/dc/terms/'
end

json.id @thing.slug

json.set! 'dct:title', @data_distribution.name
json.set! 'dct:issued', @data_distribution.created_at
json.set! 'dct:modified', @data_distribution.updated_at

json.set! 'dcat:accessURL', request.protocol+request.host_with_port+attachment_url(@data_distribution, :file) if @data_distribution.file
json.set! 'dcat:mediaType', @data_distribution.file_content_type
json.set! 'dcat:byteSize', @data_distribution.file_size

json.set! 'sin:extension', Rack::Mime::MIME_TYPES.invert[@data_distribution.file_content_type].to_s[1..-1]

