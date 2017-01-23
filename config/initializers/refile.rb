require "refile/s3"

# If environmental variables were set up correctly, try to use S3; otherwise - local storage
if !!ENV["S3_BUCKET_NAME"] && !!ENV["S3_ACCESS_KEY_ID"] && !!ENV["S3_ACCESS_KEY_SECRET"] && !!ENV["S3_REGION"] then
  aws = {
    access_key_id: ENV["S3_ACCESS_KEY_ID"],
    secret_access_key: ENV["S3_ACCESS_KEY_SECRET"],
    region: ENV["S3_REGION"],
    bucket: ENV["S3_BUCKET_NAME"],
    }
  Refile.cache = Refile::S3.new(prefix: "cache", **aws)
  Refile.store = Refile::S3.new(prefix: "store", **aws)
else
  Refile.store ||= Refile::Backend::FileSystem.new("/tmp/refile_uploads/store".to_s)
  Refile.cache ||= Refile::Backend::FileSystem.new("/tmp/refile_uploads/cache".to_s)
end



