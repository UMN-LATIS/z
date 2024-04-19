require_relative "boot"

# CSV is part of standard library, so it needs to be explicitly required
require 'csv'
require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Z
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    config.time_zone = 'Central Time (US & Canada)'
    # config.eager_load_paths << Rails.root.join("extras")

    # disable ip spoofing check, as it looks like users behind badly behaving
    # proxies will now trigger it due to the f5
    config.action_dispatch.ip_spoofing_check = false

    config.middleware.insert 0, Rack::UTF8Sanitizer
    config.middleware.use Rack::Deflater

    config.exceptions_app = routes
  end
end
