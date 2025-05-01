class SamlMetadataController < ApplicationController
  def metadata
    settings = Rails.application.config.omni_auth_saml
    metadata = OneLogin::RubySaml::Metadata.new
    render xml: metadata.generate(settings)
  end
end