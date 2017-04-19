# Z


## Running with Docker ##

The included docker-composer.yml and Dockerfile files should allow this application to be run in Docker.  To get started, run `docker-compose run web rake db:create` followed by `docker-compose run web rails db:migrate RAILS_ENV=development`.  To launch the application, run `docker-compose up` and connect to your localhost on port 3000.