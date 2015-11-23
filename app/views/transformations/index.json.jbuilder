json.array!(@transformations) do |transformation|
  json.extract! transformation, :id
  json.url thing_url(transformation, format: :json)
end
