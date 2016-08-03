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
    setup_filters
    if @query_type.eql? "name"
      search_by_name
    elsif @query_type.eql? "uid"
      search_by_uid
    elsif @query_type.eql? "all"
      search_all_criteria
    end
  end

  private

  def setup_filters
    @cn_filter = Net::LDAP::Filter.eq("cn", "#{@query.tr ' ', '*'}*")
    @uid_filter = Net::LDAP::Filter.eq("uid", "#{@query}*")
  end

  def search_all_criteria
    if @connection.bind
      results = @connection.search(
          filter: Net::LDAP::Filter.join(@cn_filter, @uid_filter),
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

  def search_by_name
    if @connection.bind
      results = @connection.search(
          filter: Net::LDAP::Filter.eq('cn', @cn_filter),
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

  def search_by_uid
    if @connection.bind
      results = @connection.search(
          filter: Net::LDAP::Filter.eq('uid', @uid_filter),
          return_result: true
      ) #.map(&:displayname).flatten
      results = results.map { |x| {value: x.try(:displayname), uid: x.try(:uid), first_name: x.try(:givenname), last_name: x.try(:sn), email: x.try(:mail)} }.flatten unless results.blank?
      return results
    else
      # authentication has failed
      puts "Result: #{@connection.get_operation_result.code}"
      puts "Message: #{@connection.get_operation_result.message}"
    end
  end


end