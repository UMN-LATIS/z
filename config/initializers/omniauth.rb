Rails.application.config.middleware.use OmniAuth::Builder do
  provider :developer unless Rails.env.production? || Rails.env.staging? || Rails.env.remotedev?
  provider :shibboleth, {
    uid_field: 'umnDID',
    :extra_fields => [
      :isGuest
    ]
  }
  provider :shibboleth_passive, {
    uid_field: 'umnDID',
    :extra_fields => [
      :isGuest
    ]
  }
end

OmniAuth.config.logger = Rails.logger

# See: https://github.com/omniauth/omniauth/wiki/Resolving-CVE-2015-9284
# We're using shibboleth and not Oauth for authentication.
OmniAuth.config.allowed_request_methods = [:post, :get]