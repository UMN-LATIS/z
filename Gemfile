source 'https://rubygems.org'

gem 'passenger'

gem 'ajax-datatables-rails', github: 'jbox-web/ajax-datatables-rails', ref: '70513cb0e0990f26b52626ba13674e67104c03c6'
# Use OmniAuth to support any type of auth
gem 'omniauth'
gem 'omniauth-shibboleth'
gem 'omniauth-shibboleth-passive'

# temporary hack due to mimemagic update
# rails 5.2.5 seems to break the app??

# gem 'mimemagic', github: 'mimemagicrb/mimemagic', ref: '01f92d86d15d85cfd0f20dabd025dcbd36a8a60f'
# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.2.0'
# Use mysql2 as the database for Active Record
gem 'mysql2'
# Use sqlite also
gem 'sqlite3'
# Use Puma as the app server
gem 'puma', '~> 3.0'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

gem 'lograge'

# For javascript translations
gem 'i18n-js'

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5.x'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'

# Use this as the autocompleter library
gem 'twitter-typeahead-rails', git: 'https://github.com/pgate/twitter-typeahead-rails.git'

# Use net-ldap for LDAP lookup integration
gem 'net-ldap'

# Use bootstrap for styling
gem 'twitter-bootstrap-rails'
# Use special bootstrap select
gem 'bootstrap-select-rails'
# Use font awesome for icons
gem 'font-awesome-rails'

# Use clipboard js plugin
gem 'clipboard-rails'

# better confirm dialogs
gem 'data-confirm-modal'

# use papertrail for auding or versioning
gem 'paper_trail'

# Use barby to generate QR codes
gem 'barby'
gem 'chunky_png'
gem 'rqrcode'

# authorization lugin
gem 'pundit'

# announcements to the seething masses
# https://github.com/csm123/starburst#
gem 'starburst', git: 'https://github.com/csm123/starburst.git'

# notify someone when exceptions occur
# and notify slack channel
gem 'exception_notification'
gem 'slack-notifier'

# For URL migration
gem 'addressable'

# For API Authentication
gem 'jwt'

gem 'sentry-rails'
gem 'sentry-ruby'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a
  # debugger console
  gem 'byebug', platform: :mri

  # Use Rspec, capybara, and apparition for testing
  gem 'apparition'
  gem 'capybara'
  gem 'database_cleaner'
  gem 'factory_bot_rails'
  gem 'fuubar'
  gem 'launchy'
  gem 'rspec-rails'

  # Add some pry/rails console helpers for development
  gem 'awesome_print'
  gem 'pry', '0.12.2'
  gem 'pry-byebug'
  gem 'pry-coolline'
  gem 'pry-rails'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere
  # in the code.
  gem 'listen', '~> 3.0.5'
  gem 'web-console'
  # Spring speeds up development by keeping your application running in the
  # background. Read more: https://github.com/rails/spring

  # Use better_errors to have more clear error messages and an interactive shell
  gem 'better_errors'
  gem 'binding_of_caller'

  # rubocop for styled code
  gem 'rubocop', require: false
  gem 'rubocop-rails', require: false

  # Use annotate to list the attributes of models
  gem 'annotate'

  gem 'capistrano'
  gem 'capistrano-bundler'
  gem 'capistrano-passenger', '>= 0.1.1'
  gem 'capistrano-rails'
  gem 'capistrano-rbenv'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

gem 'browser'
