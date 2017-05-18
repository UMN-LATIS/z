# app/services/user_lookup_service.rb
require 'net/ldap' # gem install net-ldap

class UserLookupService
  def initialize(params = nil)
    @connection = Net::LDAP.new(
      YAML.load(File.open('config/ldap.yml'))
    )
    @query = params[:query] if params
    @query_type = params[:query_type] if params
  end

  def ping
    begin
      @connection.bind
    rescue Net::LDAP::ConnectionRefusedError
      return false
    end
    true
  end

  def search
    return nil unless @query.present? && @query_type.present?
    results = Rails.cache.fetch("#{@query}/#{@query_type}/search", expires_in: 12.hours) do
      if @connection.bind
        @connection.search(
          filter: get_filter,
          return_result: true
        )
      end
    end
    return nil unless results
    results = results.promote(results.detect { |x| x[:uid] == [@query] })
    results = results.map { |x| { umndid: x.try(:umndid), value: display_name(x), uid: x.try(:uid), first_name: x.try(:givenname), last_name: x.try(:sn), email: x.try(:mail) } }.flatten unless results.blank?
    results
  end

  private

  def display_name(x)
    name = x.try(:displayname)[0] ? x.try(:displayname)[0] : 'No Name'
    mail = x.try(:mail) ? x.try(:mail)[0] : 'No Email'
    "#{name} (#{mail})"
  end

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
