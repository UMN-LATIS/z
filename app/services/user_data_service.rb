class UserDataService

  # given the search string go to whatever
  # and query it. instantiate Users with results,
  # put in an array and return it to caller
  def self.search_for_user_data search_string
    candidates = []
    results = [] # put results in result array

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
  def self.load_user_data user
    user.first_name = "Bob"
    user.last_name = "Smith"
    user.email = "bob@abc.com"
  end

end