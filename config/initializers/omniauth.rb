Rails.application.config.middleware.use OmniAuth::Builder do
    if Rails.application.config.omniauth_provider == 'developer'
      provider :developer
    else
      provider :saml, Rails.application.config.shib_settings
    end
end


OmniAuth.config.logger = Rails.logger

OmniAuth.config.allowed_request_methods = %i[post]
