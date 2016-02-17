json.array!(@utility_functions) do |utility_function|
  json.extract! utility_function, :id, :name, :public
  json.url thing_url(utility_function, format: :json)
end
