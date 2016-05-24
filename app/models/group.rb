class Group < ApplicationRecord
  has_and_belongs_to_many :users, join_table: GroupsUser
  # this next bit of magic removes any associations in the group_users table
  before_destroy {|group| group.users.clear}
end
