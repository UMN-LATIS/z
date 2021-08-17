# app/services/user_lookup_service.rb
require 'net/ldap' # gem install net-ldap

class UserLookupService
  def initialize(params = nil)
    # ldap.yml may contain embedded erb to
    # fetch environment variables so parse this
    # before loading the config
    raw_config = File.read('config/ldap.yml')
    processed_config = ERB.new(raw_config).result

    @connection = Net::LDAP.new(YAML.load(processed_config))
    @query = params[:query] if params
    @query_type = params[:query_type] if params
  end

  def search
    return nil unless @query.present? && @query_type.present?

    results = nil
    if @connection.bind
      if @query_type == 'all'
        cn_filter = Net::LDAP::Filter.eq('displayname', "*#{@query.squish.gsub(/\s/, '* ')}*")
        uid_exact_filter = Net::LDAP::Filter.eq('uid', @query)
        uid_filter = Net::LDAP::Filter.eq('uid', "#{@query}*")
        results1 = @connection.search(
          filter: uid_exact_filter,
          return_result: true,
          size: 1
        )
        results1 = [] if results1.nil?
        results2 = @connection.search(
          filter: (uid_filter | cn_filter) & Net::LDAP::Filter.negate(uid_exact_filter),
          return_result: true,
          size: 10
        )
        results2 = [] if results2.nil?
        results = (results1 + results2)
      elsif @query_type == 'umndid'
        results = @connection.search(
          filter: Net::LDAP::Filter.eq('umndid', @query),
          return_result: true,
          size: 1
        )
      elsif @query_type == 'uid'
        results = @connection.search(
          filter: Net::LDAP::Filter.eq('uid', @query),
          return_result: true,
          size: 1
        )
      end
    end
    return nil unless results

    results = results.promote(results.detect { |x| x[:uid] == [@query] })
    if results.present?
      results = results.map do |x|
        { umndid: umndid(x), display: display(x), internet_id: internet_id(x),
          display_name: result_name(x) }
      end.flatten
    end
    results
  end

  private

  def umndid(x)
    x.try(:umndid).try(:first)
  end

  def display_name(x)
    x.try(:displayname).try(:first) || 'Name not available'
  end

  def result_name(x)
    x.try(:displayname).try(:first) || '(name not available)'
  end

  def internet_id(x)
    x.try(:uid).try(:first) || 'Internet ID not available'
  end

  def display(x)
    "#{display_name(x)} (#{internet_id(x)})"
  end
end
