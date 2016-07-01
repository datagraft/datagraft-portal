json.array!(@filestores) do |filestore|
  json.extract! filestore, :id
  json.url thing_url(filestore)
end
