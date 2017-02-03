# app/services/user_lookup_service.rb
require 'net/ldap' # gem install net-ldap

class UserLookupService
  def initialize(params)
    # @connection = Net::LDAP.new(
    #   host: 'ldap.umn.edu',
    #   port: 389,
    #   base: 'o=University of Minnesota, c=US'
    # )

    @connection = Net::LDAP.new(
      host: 'ldapauth.umn.edu',
      port: 4636,
      encryption: :simple_tls,
      base: 'o=University of Minnesota, c=US',
      auth: {
       method: :simple,
       username: 'cn=CLAOIT Elevator LDAP Access,ou=Organizations,o=University of Minnesota,c=US',
       password: 'vise587\item'
      }
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
      results = results.promote(results.detect { |x| x[:uid] == [@query] })
      results = results.map { |x| { umndid: x.try(:umndid), value: display_name(x), uid: x.try(:uid), first_name: x.try(:givenname), last_name: x.try(:sn), email: x.try(:mail) } }.flatten unless results.blank?
      # Promote Internet id match
      # Promote emplid match

      return results
    else
      # authentication has failed
      puts "Result: #{@connection.get_operation_result.code}"
      puts "Message: #{@connection.get_operation_result.message}"

    end
  end

  private

  def display_name(x)
    name = x.try(:displayname)[0] ? x.try(:displayname)[0] : 'No Name'
    mail = x.try(:mail) ? x.try(:mail)[0] : 'No Email'
    "#{name} (#{mail})"
  end

  def get_filter
    sn_filter = Net::LDAP::Filter.eq('sn', "#{@query.squish.gsub(/\s/,'*')}*")
    cn_filter = Net::LDAP::Filter.eq('cn', "#{@query.squish.gsub(/\s/,'* ')}*")
    uid_filter = Net::LDAP::Filter.eq('uid', "#{@query}*")
    mail_filter = Net::LDAP::Filter.eq('mail', "#{@query}*")
    umndid_filter = Net::LDAP::Filter.eq('umndid', "#{@query}")
    if @query_type.eql? 'last_name'
      return sn_filter
    elsif @query_type.eql? 'uid'
      return uid_filter
    elsif @query_type.eql? 'umndid'
      return umndid_filter
    elsif @query_type.eql? 'mail'
      return mail_filter
    elsif @query_type.eql? 'all'
      x = Net::LDAP::Filter.intersect(cn_filter, uid_filter)
      return Net::LDAP::Filter.intersect(x, mail_filter)
    end
  end
end
