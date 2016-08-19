# app/services/user_lookup_service.rb
require 'net/ldap' # gem install net-ldap

class UserLookupService

  def initialize(params)
    @connection = Net::LDAP.new(
        host: 'ldap.umn.edu',
        port: 389,
        base: 'o=University of Minnesota, c=US'
    )
    @query = params[:query]
    @query_type = params[:query_type]
  end

  def search
    return nil unless @query.present? && @query_type.present?
    if @connection.bind
      results = @connection.search(
          filter: get_filter,
          return_result: true
      )
      results = results.map { |x| {value: display_name(x), uid: x.try(:uid), first_name: x.try(:givenname), last_name: x.try(:sn), email: x.try(:mail)} }.flatten unless results.blank?
      return results
    else
      #authentication has failed
      puts "Result: #{@connection.get_operation_result.code}"
      puts "Message: #{@connection.get_operation_result.message}"
    end
  end

  private

  def display_name(x)
    name = x.try(:displayname)[0] ?  x.try(:displayname)[0] : 'No Name'
    mail = x.try(:mail) ? x.try(:mail)[0] : 'No Email'
    "#{name} (#{mail})"
  end

  def get_filter
    sn_filter = Net::LDAP::Filter.eq('sn', "#{@query}*")
    uid_filter = Net::LDAP::Filter.eq('uid', "#{@query}*")
    mail_filter = Net::LDAP::Filter.eq('mail', "#{@query}*")
    if @query_type.eql? 'last_name'
      return sn_filter
    elsif @query_type.eql? 'uid'
      return uid_filter
    elsif @query_type.eql? 'mail'
      return mail_filter
    elsif @query_type.eql? 'all'
      x = Net::LDAP::Filter.intersect(sn_filter, uid_filter)
      return Net::LDAP::Filter.intersect(x, mail_filter)
    end
  end

end