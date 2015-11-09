json.array!(@quota) do |quotum|
  json.extract! quotum, :id
  json.url quotum_url(quotum, format: :json)
end
