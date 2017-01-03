# DataGraft Portal

This repository contains the implementation for the graphical user interface (views) and corresponding user services (user interface controllers and models) that defines the portal component of the DataGraft Platform.

The portal serves several functions. Firstly, it provides the web-based front-end that is used by the data publishers. Internally, it implements the data model and provides object-relational mapping between it and the database back-end. It also enables the communication with the database and manages the storage of uploaded files (Docker volume, or Amazon RDS in production). Finally, this component implements the connection to the data hosting and access services.

## How to build

`docker build -t datagraft . `

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

## Running tests

### The test environment and DB

Test folder: /test/
Environment: RAILS_ENV=test
Test database (datagraft-test)
Erased and re-generated from your development database

Tests are generated any time the Rails generator is used

### Test structure

Test helper (test_helper.rb)
Default configuration for all tests
Should contain and/or inherit modules for all tests
Base class – ActiveSupport::TestCase (test_helper.rb)
Naming test methods 
Use readable names - test framework takes care of it!
	test "my method name however I want it"

```sh
require 'test_helper'

class SparqlEndpointTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end

```

## Questions or issues?

For posting information about bugs, questions and discussions please use the [Github Issues](https://github.com/datagraft/datagraft-portal/issues) feature.

## Core Team

- [Nikolay Nikolov](https://github.com/nvnikolov)
- [Antoine Pultier](https://github.com/yellowiscool)
- [Brian Elvesæter](https://github.com/elvesater)
- [Steffen Dalgard](https://github.com/sdalgard)
- [Ana Tarita](https://github.com/taritaAna)

## License

Available under the [Eclipse Public License](/LICENSE) (v1.0).
