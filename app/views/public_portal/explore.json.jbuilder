json.array!(@things) do |thing|
  json.extract! thing, :id, :slug, :name, :code, :created_at, :updated_at
  json.class thing.class.name
  json.owner thing.user.username
  json.url thing_url(thing)
end
