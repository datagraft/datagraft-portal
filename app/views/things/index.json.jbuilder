json.array!(@things) do |thing|
  json.extract! thing, :id, :user_id, :public, :stars_count, :name, :code, :type
  json.url thing_url(thing, format: :json)
end
