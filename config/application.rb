require_relative "boot"

# CSV is part of standard library, so it needs to be explicitly required
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

    ###
    # No longer add autoloaded paths into `$LOAD_PATH`. This means that you won't be able
    # to manually require files that are managed by the autoloader, which you shouldn't do anyway.
    #
    # This will reduce the size of the load path, making `require` faster if you don't use bootsnap, or reduce the size
    # of the bootsnap cache if you use it.
    #
    # To set this configuration, add the following line to `config/application.rb` (NOT this file):
    config.add_autoload_paths_to_load_path = false

    # Change the format of the cache entry.
    #
    # Changing this default means that all new cache entries added to the cache
    # will have a different format that is not supported by Rails 7.0
    # applications.
    #
    # Only change this value after your application is fully deployed to Rails 7.1
    # and you have no plans to rollback.
    # config.active_support.cache_format_version = 7.1
    config.active_support.cache_format_version = 7.0

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
    config.middleware.insert_before Rack::Runtime, HandleBadEncodingMiddleware

    config.exceptions_app = routes

    ##
    # The Papertrail gem serializes YAML in the DB, so we explicitly allow
    # classes it needs. Without it, we get errors like:
    # > Tried to load unspecified class: Time (Psych::DisallowedClass)
    #
    # See Also: https://discuss.rubyonrails.org/t/cve-2022-32224-possible-rce-escalation-bug-with-serialized-columns-in-active-record/81017
    ##
    config.active_record.yaml_column_permitted_classes = [Symbol, Date, Time]
  end
end
