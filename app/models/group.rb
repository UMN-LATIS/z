class Group < ApplicationRecord
  
  has_and_belongs_to_many :users, join_table: :groups_users
  # this next bit of magic removes any associations in the group_users table
  before_destroy {|group| group.users.clear}
  
  has_many :users, foreign_key: :context_group_id, dependent: :nullify
end
