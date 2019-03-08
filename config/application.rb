require_relative 'boot'

require 'csv'
require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Z
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set default time zone
    config.time_zone = 'Central Time (US & Canada)'
    config.middleware.insert_before Rack::Runtime, 'InvalidDataInterceptor'
    config.action_dispatch.ip_spoofing_check = false
    config.middleware.use Rack::Deflater
  end
end
