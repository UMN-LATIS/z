class UserDataService

  # given the search string go to whatever
  # and query it. instantiate Users with results,
  # put in an array and return it to caller
  def self.search_for_user_data search_string=nil
    candidates = []
    results = [
        User.new(:uid => uid, :first_name => "Alice1", :last_name => "Cooper1", :email => "alice1@abc.com"),
        User.new(:uid => uid, :first_name => "Alice2", :last_name => "Cooper2", :email => "alice2@abc.com"),
        User.new(:uid => uid, :first_name => "Alice3", :last_name => "Cooper3", :email => "alice3@abc.com"),
        User.new(:uid => uid, :first_name => "Alice4", :last_name => "Cooper4", :email => "alice4@abc.com"),
        User.new(:uid => uid, :first_name => "Alice5", :last_name => "Cooper5", :email => "alice5@abc.com"),
        User.new(:uid => uid, :first_name => "Alice6", :last_name => "Cooper6", :email => "alice6@abc.com"),
        User.new(:uid => uid, :first_name => "Alice7", :last_name => "Cooper7", :email => "alice7@abc.com"),
        User.new(:uid => uid, :first_name => "Alice8", :last_name => "Cooper8", :email => "alice8@abc.com")
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
  def self.load_user_data user
    user.first_name = "Bob"
    user.last_name = "Smith"
    user.email = "bob@abc.com"
  end

end