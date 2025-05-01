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
    certificate: "-----BEGIN CERTIFICATE-----\nMIIFHTCCBAWgAwIBAgIBADANBgkqhkiG9w0BAQUFADCBvzELMAkGA1UEBhMCVVMx\nEjAQBgNVBAgTCU1pbm5lc290YTEUMBIGA1UEBxMLTWlubmVhcG9saXMxIDAeBgNV\nBAoTF1VuaXZlcnNpdHkgb2YgTWlubmVzb3RhMSAwHgYDVQQLExdDb2xsZWdlIG9m\nIExpYmVyYWwgQXJ0czEkMCIGA1UEAxMbc2hpYi1kZWZhdWx0LmNsYW9pdC51bW4u\nZWR1MRwwGgYJKoZIhvcNAQkBFg00aGVscEB1bW4uZWR1MB4XDTEyMDUwODAwMTIz\nOVoXDTE0MDUwODAwMTIzOVowgb8xCzAJBgNVBAYTAlVTMRIwEAYDVQQIEwlNaW5u\nZXNvdGExFDASBgNVBAcTC01pbm5lYXBvbGlzMSAwHgYDVQQKExdVbml2ZXJzaXR5\nIG9mIE1pbm5lc290YTEgMB4GA1UECxMXQ29sbGVnZSBvZiBMaWJlcmFsIEFydHMx\nJDAiBgNVBAMTG3NoaWItZGVmYXVsdC5jbGFvaXQudW1uLmVkdTEcMBoGCSqGSIb3\nDQEJARYNNGhlbHBAdW1uLmVkdTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoC\nggEBAO9LgY4oD40Q4OXfWK8olaFD+9iPEvbsyywNkxDKfcbBn9q9rAAQYpW6DiI1\n+M/e5Lh+p8v9IXzYjiyWcQPlPbZz40HC6qCwzLu90f82MWJ+ov7mwhoqslDV1gIE\n9yEKV7DsjnDf3iQIj/ZDECPoaUSB4MtqgODJFcHL+t0zjXG229z+BmlTT9z9thdK\nJGkKVDWMnEdA8azHEOjn7N1jWrP0OOE5qhcLcVyd3a4UJRM7J9xB+Hb0wHKPUSpi\nfH8fyhBUIcSQRx0DH51Kd4z+Etl4zobr/zFKUxPvDiuU6bPtYoAZZdUuMzP8EQZg\nHFFL6vQjT1J1zbUpf7tpmGfK8a0CAwEAAaOCASAwggEcMB0GA1UdDgQWBBRYD2/A\nHhRNHULHOG1sBLfRAqVSZDCB7AYDVR0jBIHkMIHhgBRYD2/AHhRNHULHOG1sBLfR\nAqVSZKGBxaSBwjCBvzELMAkGA1UEBhMCVVMxEjAQBgNVBAgTCU1pbm5lc290YTEU\nMBIGA1UEBxMLTWlubmVhcG9saXMxIDAeBgNVBAoTF1VuaXZlcnNpdHkgb2YgTWlu\nbmVzb3RhMSAwHgYDVQQLExdDb2xsZWdlIG9mIExpYmVyYWwgQXJ0czEkMCIGA1UE\nAxMbc2hpYi1kZWZhdWx0LmNsYW9pdC51bW4uZWR1MRwwGgYJKoZIhvcNAQkBFg00\naGVscEB1bW4uZWR1ggEAMAwGA1UdEwQFMAMBAf8wDQYJKoZIhvcNAQEFBQADggEB\nALDiiZ0+jsLDShgdsrc1YTjrOP0SSqsl8k0zKthnZUwMaNpThSOdbZ+ff6Xo8LsU\nlA3QrZOM2VwKy73mHL3N0mrcgAc7/5CTRByxvwvNBeD1zH8bzMB5l6JowkIh0T/W\n4oqUgIg0aWVej3MJzOyYyrV431cSDJjIadIiLjaIP2VGpj55coSkjkG05JxNhnn2\nvk8kVIaNRtnMEJYkJJ7dZYGAO382iio+UyMSj7sus2N97YhQkmYwuyypjRQx2tR2\nhT9TcPLmgWaRK048Wvz48kYQ1rFxmFqHbvd4ZbHnuMU2850AezXU0T4C/hlcADGX\n8TS1V7qmy5U2tUSS3Ocz/ac=\n-----END CERTIFICATE-----",
    private_key: "snip",
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
