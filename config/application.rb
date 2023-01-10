require_relative 'boot'

require 'csv'
require 'rails/all'

# Handle bad url encodings
require_relative '../app/middleware/handle_bad_encoding_middleware'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Z
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set default time zone
    config.time_zone = 'Central Time (US & Canada)'
    # config.middleware.insert_before Rack::Runtime, 'InvalidDataInterceptor'
    config.action_dispatch.ip_spoofing_check = false

    config.middleware.insert 0, Rack::UTF8Sanitizer
    config.middleware.use Rack::Deflater
    config.middleware.insert_before Rack::Runtime, HandleBadEncodingMiddleware

    config.exceptions_app = routes
  end
end
