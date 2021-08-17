Sentry.init do |config|
  config.dsn = Rails.application.secrets.sentry_dsn
  config.breadcrumbs_logger = [:active_support_logger]

  # Set tracesSampleRate to 1.0 to capture 100%
  # of transactions for performance monitoring.
  # We recommend adjusting this value in production
  config.traces_sample_rate = if Rails.env.production?
                                0
                              else
                                0.5
                              end
end
