require "refile/s3"

# If environmental variables were set up correctly, try to use S3; otherwise - local storage
if !!ENV["AWS_S3_BUCKET_NAME"] && !!ENV["AWS_S3_ACCESS_KEY_ID"] && !!ENV["AWS_S3_ACCESS_KEY_SECRET"] && !!ENV["AWS_S3_REGION"] then
  aws = {
    access_key_id: ENV["AWS_S3_ACCESS_KEY_ID"],
    secret_access_key: ENV["AWS_S3_ACCESS_KEY_SECRET"],
    region: ENV["AWS_S3_REGION"],
    bucket: ENV["AWS_S3_BUCKET_NAME"],
    }
  Refile.cache = Refile::S3.new(prefix: "cache", **aws)
  Refile.store = Refile::S3.new(prefix: "store", **aws)
else
  if ENV["REFILE_BACKEND_LOCATION"].present?
    ## Use env var in your startup if you want an alternative location
    ##   example: REFILE_BACKEND_LOCATION=/var/refile_uploads/ 
    location = ENV["REFILE_BACKEND_LOCATION"]
    puts "Using refile_backend_location <#{location}>"
    Refile.store = Refile::Backend::FileSystem.new("#{location}store".to_s)
    Refile.cache = Refile::Backend::FileSystem.new("#{location}cache".to_s)
  else
    puts "Using default refile_backend_location"
    Refile.store ||= Refile::Backend::FileSystem.new("/tmp/refile_uploads/store".to_s)
    Refile.cache ||= Refile::Backend::FileSystem.new("/tmp/refile_uploads/cache".to_s)
  end
end
