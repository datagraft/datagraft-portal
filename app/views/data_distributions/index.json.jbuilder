json.array!(@data_distributions) do |data_distribution|
  json.extract! data_distribution, :id
  json.url data_distribution_url(data_distribution, format: :json)
end
