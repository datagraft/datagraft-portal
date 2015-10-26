json.array!(@transformations) do |transformation|
  json.extract! transformation, :id
  json.url transformation_url(transformation, format: :json)
end
