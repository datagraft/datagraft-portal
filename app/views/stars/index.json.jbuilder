json.array!(@stars) do |star|
  json.extract! star, :id, :user_id, :thing_id
  json.url star_url(star, format: :json)
end
