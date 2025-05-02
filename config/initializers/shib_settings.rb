require 'onelogin/ruby-saml/idp_metadata_parser'

if ENV['OMNIAUTH_PROVIDER'] != "developer"
  # Parse IdP metadata once at boot time
  idp_metadata_parser = OneLogin::RubySaml::IdpMetadataParser.new
  idp_metadata = idp_metadata_parser.parse_remote_to_hash(ENV['SHIB_METADATA_URL'] || raise("SHIB_METADATA_URL environment variable must be defined"))

  Rails.application.config.shib_settings = {
    idp_cert_multi: idp_metadata[:idp_cert_multi],
    uid_field: ENV['SHIB_DID'],
    extra_fields: [
      ENV['SHIB_IS_GUEST']
    ],
    issuer: -> { Rails.application.config.app_base_url },
    assertion_consumer_service_url: ENV['SHIB_ASSERTION_CONSUMER_URL'],
    sp_entity_id: ENV['SHIB_ENTITY_ID'],
    idp_sso_service_url: ENV['SHIB_IDP_SSO'],
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
end

