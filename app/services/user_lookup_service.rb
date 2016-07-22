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
  end

  def search_by_name
    #candidates = []
    return nil unless @query.present?
    search_string = "#{@query.tr ' ', '*'}*"
    if @connection.bind
      results = @connection.search(
          filter: Net::LDAP::Filter.eq('cn', search_string),
          return_result: true
      )
      results = results.map { |x| {value: x.displayname, uid: x.uid} }.flatten unless results.blank?
      return results
      #results.each do |x|
      #  candidates << User.new(:uid => x.uid[0].to_s, :first_name => x.givenname[0].to_s, :last_name => x.sn[0].to_s, :email => "#{x.uid[0].to_s}@umn.edu")
      #end
      #return candidates
    end
  end

  def search_by_uid
    search_string = "#{@query}*"
    if @connection.bind
      results = @connection.search(
          filter: Net::LDAP::Filter.eq('uid', search_string),
          return_result: true
      ) #.map(&:displayname).flatten
      results = results.map { |x| {value: x.try(:displayname), uid: x.try(:uid), first_name: x.try(:givenname), last_name: x.try(:sn), email: x.try(:mail)} }.flatten unless results.blank?
      return results
    end
  end


# given the search string go to whatever
# and query it. instantiate Users with results,
# put in an array and return it to caller
  def self.search_for_user_data search_string=nil
    candidates = []
    results = [
        User.new(:uid => "uid1", :first_name => "Alice1", :last_name => "Cooper1", :email => "alice1@abc.com"),
        User.new(:uid => "uid2", :first_name => "Alice2", :last_name => "Cooper2", :email => "alice2@abc.com"),
        User.new(:uid => "uid3", :first_name => "Alice3", :last_name => "Cooper3", :email => "alice3@abc.com"),
        User.new(:uid => "uid4", :first_name => "Alice4", :last_name => "Cooper4", :email => "alice4@abc.com"),
        User.new(:uid => "uid5", :first_name => "Alice5", :last_name => "Cooper5", :email => "alice5@abc.com"),
        User.new(:uid => "uid6", :first_name => "Alice6", :last_name => "Cooper6", :email => "alice6@abc.com"),
        User.new(:uid => "uid7", :first_name => "Alice7", :last_name => "Cooper7", :email => "alice7@abc.com"),
        User.new(:uid => "uid8", :first_name => "Alice8", :last_name => "Cooper8", :email => "alice8@abc.com")
    ] # put results in result array
    results.each do |result|
      candidates << result
    end
    candidates
  end

  def self.get_new_user uid
    #take uid, get user from data source, construct a new User, populate if and return
    new_user = User.new(:uid => uid, :first_name => "Alice", :last_name => "Cooper", :email => "alice@abc.com")
  end

# given a User, go wherever and populate
# the users user_data
  def load_user_data user
    search_by_uid user.uid

    user.first_name = "Bob"
    user.last_name = "Smith"
    user.email = "bob@abc.com"
  end

end