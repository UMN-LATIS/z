# `saml` or `developer`
Rails.application.config.omniauth_provider = ENV['OMNIAUTH_PROVIDER'] || 'saml'

Rails.application.config.middleware.use OmniAuth::Builder do

    # Configure SAML provider
    if Rails.application.config.omniauth_provider == 'saml'
      provider :saml, Rails.application.config.shib_settings
    end

    if Rails.application.config.omniauth_provider == 'developer'
      provider :developer
    end
end


OmniAuth.config.logger = Rails.logger

OmniAuth.config.allowed_request_methods = %i[post]
