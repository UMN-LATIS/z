class InvalidDataInterceptor
  def initialize(app)
    @app = app
  end

  def call(env)
    query = Rack::Utils.parse_nested_query(env['QUERY_STRING'].to_s) rescue :bad_query

    headers = { 'Content-Type' => 'text/plain' }

    if query == :bad_query
      [400, headers, ['Bad Request']]
    else
      @app.call(env)
    end
  end
end
