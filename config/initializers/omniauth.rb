Rails.application.config.middleware.use OmniAuth::Builder do
  provider :developer unless Rails.env.production? || Rails.env.staging?
  provider :shibboleth, {
    uid_field: 'eppn',
    debug: true
  }

end

OmniAuth.config.logger = Rails.logger
