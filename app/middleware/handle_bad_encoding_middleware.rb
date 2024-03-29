# frozen_string_literal: true

# Handling malformed quesy strings like /?%=
class HandleBadEncodingMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    begin
      Rack::Utils.parse_nested_query(env['QUERY_STRING'].to_s)
    rescue Rack::Utils::InvalidParameterError
      env['QUERY_STRING'] = ''
    end

    @app.call(env)
  end
end
