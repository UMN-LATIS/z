idp_metadata_parser = OneLogin::RubySaml::IdpMetadataParser.new
idp_metadata = idp_metadata_parser.parse_remote_to_hash("https://login.umn.edu/metadata.xml")

Rails.application.config.middleware.use OmniAuth::Builder do
 
  provider :saml, {
    idp_cert_multi: idp_metadata[:idp_cert_multi],
    uid_field: 'https://www.umn.edu/shibboleth/attributes/umnDID',
    extra_fields: [
      'https://www.umn.edu/shibboleth/attributes/isGuest'
    ],
    issuer: "#{Rails.application.config.app_base_url}",
    assertion_consumer_service_url: "#{Rails.application.config.app_base_url}/auth/saml/callback",
    sp_entity_id: "https://claoit.umn.edu/shibboleth/default",
    idp_sso_service_url: "https://login.umn.edu/idp/profile/SAML2/Redirect/SSO",
    idp_metadata: idp_metadata,
    certificate: ENV['SHIB_X509_CERT'] || raise("SHIB_X509_CERT environment variable must be defined"),
    private_key: ENV['SHIB_PRIVATE_KEY'] || raise("SHIB_PRIVATE_KEY environment variable must be defined"),
    security: {
      metadata_signed: true,
      authn_requests_signed: true,
      signature_method: XMLSecurity::Document::RSA_SHA256,
    },
    protocol_binding: OneLogin::RubySaml::Utils::BINDINGS[:post],
    name_identifier_format: nil
  }
  # provider :shibboleth_passive, {
  #   uid_field: 'umnDID',
  #   extra_fields: [
  #     :isGuest
  #   ]
  # }
  # provider :saml,
    
end


# Rails.application.config.middleware.use OmniAuth::Builder do
#   # provider :developer unless Rails.env.production? || Rails.env.staging? || Rails.env.remotedev?
  
# end

OmniAuth.config.logger = Rails.logger

OmniAuth.config.allowed_request_methods = %i[post]
