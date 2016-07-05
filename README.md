## Datagraft return

This is a Ruby On Rails implementation of DataGraft.

## How to build

`docker build -t datagraft` . 

## How to deploy

```sh
# Create the data volume for the database
docker volume create --name datagraft-data

# Start the PostGreSQL database container
docker run --name datagraft-postgres \
  -v datagraft-data:/var/lib/postgresql/data \
  -e POSTGRES_PASSWORD=apassword \
  -e POSTGRES_DB=datagraft-prod \
  -d postgres

# Start the rails container
# The secret_key_base should obviously be changed
docker run --name datagraft-rails \
  -p 3000:3000 \
  --link datagraft-postgres:postgres \
  -e DATABASE_URL=postgresql://postgres:apassword@postgres \
  -e RAILS_ENV=production \
  -e SECRET_KEY_BASE=750184ddf9d54ca16fee171034f7e4fd7df4b8398efa30c6d36966b24f1d3460209566919a6cf05415017f2b8af7dd65e9b17e423ab95ec783773d8d36421281 \
  -e OMNIAUTH_FACEBOOK_KEY=facebookkey -e OMNIAUTH_FACEBOOK_SECRET=facebooksecret \
  -e OMNIAUTH_GITHUB_KEY=githubkey -e OMNIAUTH_GITHUB_SECRET=githubsecret \
  -d yellowiscool/datagraftreturn

# Run the database migration
docker exec datagraft-rails rake db:migrate

# (Optional) Pre-compile the assets for better performances
docker exec datagraft-rails rake assets:precompile
```