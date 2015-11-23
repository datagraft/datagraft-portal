json.array!(@data_distributions) do |data_distribution|
  json.extract! data_distribution, :id
  json.url thing_url(data_distribution)
end
