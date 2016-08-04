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
      results = results.map { |x| {value: x.try(:displayname), uid: x.try(:uid), first_name: x.try(:givenname), last_name: x.try(:sn), email: x.try(:mail)} }.flatten unless results.blank?
      return results
    else
      #authentication has failed
      puts "Result: #{@connection.get_operation_result.code}"
      puts "Message: #{@connection.get_operation_result.message}"
    end
  end

  private

  def get_filter
    if @query_type.eql? "name"
      return Net::LDAP::Filter.eq("cn", "#{@query.tr ' ', '*'}*")
    elsif @query_type.eql? "uid"
      return Net::LDAP::Filter.eq("uid", "#{@query}*")
    elsif @query_type.eql? "all"
      cn_filter = Net::LDAP::Filter.eq("cn", "#{@query.tr ' ', '*'}*")
      uid_filter = Net::LDAP::Filter.eq("uid", "#{@query}*")
      return Net::LDAP::Filter.join(cn_filter, uid_filter)
    end
  end

end