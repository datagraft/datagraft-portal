
json.set! "@id", request.protocol+request.host_with_port+wizard_path(:decide)

json.set! "@context" do
  json.dcat 'http://www.w3.org/ns/dcat#'
  json.dct 'http://purl.org/dc/terms/'
end

json.set! 'dcat:accessURL', request.protocol+request.host_with_port+attachment_url(@upwizard, :file) if @upwizard.file
json.set! 'dcat:mediaType', @upwizard.file_content_type
json.set! 'dcat:byteSize', @upwizard.file_size

json.set! 'sin:extension', Rack::Mime::MIME_TYPES.invert[@upwizard.file_content_type].to_s[1..-1]
