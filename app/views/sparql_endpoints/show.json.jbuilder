
json.set! "@id", request.protocol+request.host_with_port+thing_path(@filestore)

json.set! "@context" do
  json.dcat 'http://www.w3.org/ns/dcat#'
  json.dct 'http://purl.org/dc/terms/'
  json.foaf 'http://xmlns.com/foaf/0.1/'
end

json.id @thing.slug
json.id_num @thing.id

json.set! 'dct:title', @thing.name
json.set! 'dct:issued', @thing.created_at
json.set! 'dct:modified', @thing.updated_at

json.set! 'dcat:accessURL', @thing.uri
json.set! 'dct:extent', repository_size_param(current_user, @thing)

json.set! 'foaf:primaryTopic', thing_url(@thing)
json.set! 'dcat:public', @thing.public
json.set! 'foaf:publisher', @thing.user.username
json.set! 'dct:description', @thing.description
json.set! 'dct:license', get_license_info(@thing.license)[:path]

json.set! 'dcat:keyword' do
  kwd_list = @thing.keywords.collect {|kwd| kwd.name}
  json.array! kwd_list
end
