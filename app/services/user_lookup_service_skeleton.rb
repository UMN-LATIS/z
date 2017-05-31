# app/services/user_lookup_service_skeleton.rb

class UserLookupServiceSkeleton
  def initialize(params = nil)
    # LDAP Connection propreties
    # An example
    # @connection = Net::LDAP.new(
    #   YAML.load(File.open('config/ldap.yml'))
    # )
    @query = params[:query] if params
    @query_type = params[:query_type] if params
  end

  def ping
    true
  end

  def search
    return nil unless @query.present? && @query_type.present?

    # Query the cache or make a connection to LDAP to find results.
    # results = Rails.cache.fetch("#{@query}/#{@query_type}/search", expires_in: 12.hours) do
      # Query LDAP
      # Left as an example
      # if @connection.bind
      #   @connection.search(
      #       filter: get_filter,
      #       return_result: true
      #   )
     # end
    # end

    # Dummy results
    results = [
      umndid: [
        'testuid'
      ],
      display: 'Ryan Doe (testinternetid@umn.edu)',
      internet_id: 'testinternetid',
      display_name: 'Ryan Doe'
    ]
    results
  end

  private

  # Get the correct LDAP filter based on the query type.
  # Left as an example
  def get_filter
    if @query_type.eql? 'last_name'
      Net::LDAP::Filter.eq('sn', "#{@query.squish.gsub(/\s/, '*')}*")
    elsif @query_type.eql? 'uid'
      Net::LDAP::Filter.eq('uid', "#{@query}*")
    elsif @query_type.eql? 'umndid'
      Net::LDAP::Filter.eq('umndid', @query.to_s)
    elsif @query_type.eql? 'mail'
      Net::LDAP::Filter.eq('mail', "#{@query}*")
    elsif @query_type.eql? 'all'
      cn_filter = Net::LDAP::Filter.eq('cn', "#{@query.squish.gsub(/\s/, '* ')}*")
      uid_filter = Net::LDAP::Filter.eq('uid', "#{@query}*")
      mail_filter = Net::LDAP::Filter.eq('mail', "#{@query}*")

      x = Net::LDAP::Filter.intersect(cn_filter, uid_filter)
      Net::LDAP::Filter.intersect(x, mail_filter)
    end
  end
end
