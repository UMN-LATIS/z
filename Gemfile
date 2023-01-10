source 'https://rubygems.org'

gem 'passenger', "~> 6.0"

gem 'ajax-datatables-rails', github: 'jbox-web/ajax-datatables-rails', ref: '70513cb0e0990f26b52626ba13674e67104c03c6'
# Use OmniAuth to support any type of auth
gem 'omniauth', "~> 1.9"
gem 'omniauth-shibboleth', "~> 1.1"
gem 'omniauth-shibboleth-passive', "~> 0.1"

# temporary hack due to mimemagic update
# rails 5.2.5 seems to break the app??

# gem 'mimemagic', github: 'mimemagicrb/mimemagic', ref: '01f92d86d15d85cfd0f20dabd025dcbd36a8a60f'
# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 7.0'
# Use mysql2 as the database for Active Record
gem 'mysql2', "~> 0.5"
# Use sqlite also
gem 'sqlite3', "~> 1.4"
# Use Puma as the app server
gem 'puma', '~> 4.3'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '~> 4.2'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

gem "lograge", "~> 0.11"

# For javascript translations
gem "i18n-js", "~> 3.7"

# Use jquery as the JavaScript library
gem 'jquery-rails', "~> 4.4"
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5.2'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.10'

# Use this as the autocompleter library
gem 'twitter-typeahead-rails', git: 'https://github.com/pgate/twitter-typeahead-rails.git'

# Use net-ldap for LDAP lookup integration
gem 'net-ldap', "~> 0.16"

# Use bootstrap for styling
gem 'twitter-bootstrap-rails', git: 'https://github.com/seyhunak/twitter-bootstrap-rails.git'

# Use special bootstrap select
gem 'bootstrap-select-rails', "~> 1.13"
# Use font awesome for icons
gem "font-awesome-rails", "~> 4.7"

# Use clipboard js plugin
gem 'clipboard-rails', "~> 1.7"

# better confirm dialogs
gem 'data-confirm-modal', "~> 1.6"

# use papertrail for auding or versioning
gem 'paper_trail', "~> 12.0"

# Use barby to generate QR codes
gem 'barby', "~> 0.6"
gem 'chunky_png', "~> 1.3"
gem 'rqrcode', "~> 1.1"

# authorization lugin
gem 'pundit', "~> 2.1"

# announcements to the seething masses
# Using our own fork of starburst to support the current Rails version
gem 'starburst',  github: 'UMN-LATIS/starburst', branch: 'feature/rails-7'

# notify someone when exceptions occur
# and notify slack channel
gem 'exception_notification', "~> 4.4"
gem 'slack-notifier', "~> 2.3"

# For URL migration
gem 'addressable', "~> 2.8"

# For API Authentication
gem 'jwt', "~> 2.2"

gem "sentry-rails", "~> 4.4"
gem "sentry-ruby", "~> 4.4"

# Load ENV variables from .env file
gem 'dotenv-rails', "~> 2.7"

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a
  # debugger console
  gem 'byebug', "~> 11.1", platform: :mri

  # Use Rspec for testing
  gem 'rspec-rails', "~> 4.0"

  # rails helpers for cypress
  gem 'cypress-on-rails', '~> 1.0'

  gem 'database_cleaner', "~> 1.8"
  gem 'factory_bot_rails', "~> 6.2"
  gem 'fuubar', "~> 2.5"
  gem 'launchy', "~> 2.4"

  # for retrying flaky tests until they can be fixed
  gem "rspec-retry", "~> 0.6"

  # Watch files for changes and re-run tests
  gem 'guard', "~> 2.17"
  gem 'guard-rspec', "~> 4.7", require: false

  # Add some pry/rails console helpers for development
  gem 'awesome_print', "~> 1.8"
  gem 'pry', '~> 0.13'
  gem 'pry-byebug', "~> 3.9"
  gem 'pry-rails', "~> 0.3"
  gem 'shoulda-matchers', '~> 5.0'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere
  # in the code.
  gem 'listen', '~> 3.0'
  gem 'web-console', "~> 3.7"
  # Spring speeds up development by keeping your application running in the
  # background. Read more: https://github.com/rails/spring

  # Use better_errors to have more clear error messages and an interactive shell
  gem 'better_errors', "~> 2.7"
  gem 'binding_of_caller', "~> 1.0"

  # rubocop for linting
  gem 'rubocop', '~> 1.18', require: false
  gem "rubocop-performance", "~> 1.11", require: false
  gem "rubocop-rails", "~> 2.11", require: false
  gem "rubocop-rake", "~> 0.6.0", require: false
  gem "rubocop-rspec", "~> 2.4", require: false

  # Use annotate to list the attributes of models
  gem 'annotate', "~> 3.1"

  gem 'bcrypt_pbkdf', "~> 1.1"
  gem 'capistrano', "~> 3.14"
  gem 'capistrano-bundler', "~> 1.6"
  gem 'capistrano-passenger', '~> 0.2'
  gem 'capistrano-rails', "~> 1.5"
  gem 'capistrano-rbenv', "~> 2.1"
  gem 'ed25519', "~> 1.2"
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

gem 'browser', "~> 4.2"

gem "webpacker", "~> 5.4"

gem "rack-utf8_sanitizer", "~> 1.7"
