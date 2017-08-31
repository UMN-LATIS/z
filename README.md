# Z

Z is a custom URL shortener developed at LATIS@UMN. Instead of using a third party service, we use Z to create and manage University branded short links, for example: http://z.umn.edu/mycoolsite. The goal of this project is to provide a modern, open source solution to University branded short links.

## Features

- Custom or generated link keywords
- QR code generation
- Click statistics
- Link organization into collections
- Sharing link management between users
- Integration with University directory
- Ownership transfer of links
- Administrative dashboard
- History of link changes
- Responsive design

## Installation ([Docker](https://www.docker.com))

The included `docker-composer.yml` and `Dockerfile` files should allow this application to be run in [Docker](https://www.docker.com). To get started, run

	 docker-compose run web rake db:create
	 docker-compose run web rails db:migrate RAILS_ENV=development

 To launch the application, run

	 docker-compose up

 and connect to your localhost on port 3000.

## Installation (Dockerless)
[TODO] Install this fresh and see what you have to do...

## Technology and Dependencies
- Rails 5.0.2
- MySQL

### Auth
- [OmniAuth](https://github.com/omniauth/omniauth), for authentication
- [Pundit](https://github.com/elabs/pundit), for authorization
### Deployment
- [Capistrano](https://github.com/capistrano/capistrano), for deployment
- Apache/[Passenger](https://github.com/phusion/passenger), as our server stack

### Testing
- [Rspec](https://github.com/rspec/rspec)/[Capybara](https://github.com/teamcapybara/capybara), for testing
- [PhantomJS](http://phantomjs.org)/[Poltergeist](https://github.com/teampoltergeist/poltergeist), for browser emulation

The application has a a comprehensive testing suite using Rspec and Capybara. Front end tests are configured to run with PhantomJS and Poltergeist. The test suite can be ran by running:

	rspec

### Other tech
- [Paper trail](https://github.com/airblade/paper_trail), for URL version history
- [Turbolinks](https://github.com/turbolinks/turbolinks), for faster browsing
- [Typeahead](https://github.com/twitter/typeahead.js/), for user autocomplete
- [Google Charts](https://developers.google.com/chart/), for click visualization
- [Barby](https://github.com/toretore/barby), for QR code generation
- [Rubocop](https://github.com/bbatsov/rubocop), to enforce best practices

## Customization
Z was designed to be forkable and customizable. Most of the language has been extracted into a [single localization file](https://github.umn.edu/latis-sw/z/blob/develop/config/locales/en.bootstrap.yml). This allows you to change any language and make Z applicable to your environment. Z uses [OmniAuth](https://github.com/omniauth/omniauth), which supports a wide variety of [authentication strategies](https://github.com/omniauth/omniauth/wiki/list-of-strategies).

## Contribute

- Issue Tracker: https://github.umn.edu/latis-sw/z/issues
- Source Code: https://github.umn.edu/latis-sw/z

## Support

If you are having issues, please let us know.
We have a mailing list located at: help@umn.edu
