# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy.
# See the Securing Rails Applications Guide for more information:
# https://guides.rubyonrails.org/security.html#content-security-policy-header

Rails.application.configure do
  config.content_security_policy do |policy|
    #     policy.default_src :self, :https
    #     policy.font_src    :self, :https, :data
    #     policy.img_src     :self, :https, :data
    #     policy.object_src  :none
    #     policy.script_src  :self, :https

    # You may need to enable this as well depending on your setup.
    # policy.script_src(*policy.script_src, :blob) if Rails.env.test?

    # For vite rails dev setup, need to specify specify vite dev server host
    # including both localhost and 127.0.0.1 to accommodate an issue with host:
    # on vpn it wants to be "127.0.0.1",
    # while on local it wants to be "localhost"
    if Rails.env.development?
      # Allow @vite/client to hot reload javascript changes in development
      policy.script_src(*policy.script_src,
                        :self,
                        :https,
                        :unsafe_eval,
                        :unsafe_inline,
                        "http://#{ViteRuby.config.host_with_port}")

      policy.connect_src :self,
                         :https,
                         "http://localhost:#{ViteRuby.config.port}",
                         "http://127.0.0.1:#{ViteRuby.config.port}",
                         "ws://localhost:#{ViteRuby.config.port}",
                         "ws://127.0.0.1:#{ViteRuby.config.port}"
    end

    #     policy.style_src   :self, :https
    # Allow @vite/client to hot reload style changes in development
    # policy.style_src *policy.style_src, :unsafe_inline if Rails.env.development?

    #     # Specify URI for violation reports
    #     # policy.report_uri "/csp-violation-report-endpoint"
  end
  #
  #   # Generate session nonces for permitted importmap, inline scripts, and inline styles.
  #   config.content_security_policy_nonce_generator = ->(request) { request.session.id.to_s }
  #   config.content_security_policy_nonce_directives = %w(script-src  style-src)
  #
  #   # Report violations without enforcing the policy.
  #   # config.content_security_policy_report_only = true
end
