Rails.application.config.middleware.use OmniAuth::Builder do
  provider :developer unless Rails.env.production? || Rails.env.staging?
  provider :shibboleth, {
    uid_field: 'umnDID'
  }
  provider :shibboleth_passive, {
    uid_field: 'umnDID'
  }
end

OmniAuth.config.logger = Rails.logger
