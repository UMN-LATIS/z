source 'https://rubygems.org'

gem 'passenger'

# Use OmniAuth to support any type of auth
gem 'omniauth'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '>= 5.0.0', '< 5.1'
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
gem 'coffee-rails', '~> 4.1.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5.x'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'

# Use this as the autocompleter library
gem 'twitter-typeahead-rails'

# Use net-ldap for LDAP lookup integration
gem 'net-ldap'

# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Use bootstrap for styling
gem 'twitter-bootstrap-rails'

# better confirm dialogs
gem 'data-confirm-modal'


# Use barby to generate QR codes
gem 'rqrcode'
gem 'barby'
gem 'chunky_png'

# authorization lugin
gem "pundit"


# For country information
gem 'geocoder'

group :development, :test do

  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :mri

  # Use Rspec, capybara, and poltergeist for testing
  gem 'rspec-rails'
  gem 'capybara'
  gem 'poltergeist'
  gem 'launchy'
  gem 'factory_girl_rails'
  gem 'database_cleaner'
  gem 'fuubar'

  # Add some pry/rails console helpers for development
  gem 'pry-coolline'
  gem 'pry-byebug'
  gem 'awesome_print'
  gem 'pry-rails'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console'
  gem 'listen', '~> 3.0.5'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'

  # Use better_errors to have more clear error messages and an interactive shell
  gem 'better_errors'
  gem 'binding_of_caller'

  # rubocop for styled code
  gem 'rubocop', '~> 0.40.0', require: false

  # Use annotate to list the attributes of models
  gem 'annotate'

  gem 'capistrano'
  gem 'capistrano-bundler'
  gem 'capistrano-passenger', '>= 0.1.1'
  gem 'capistrano-rbenv'
  gem 'capistrano-rails'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
