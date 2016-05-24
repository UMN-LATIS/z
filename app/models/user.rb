class User < ApplicationRecord
  has_and_belongs_to_many :groups, join_table: GroupsUser
  # this next bit of magic removes any associations in the group_users table
  before_destroy {|user| user.groups.clear}
  belongs_to :group, foreign_key: 'context_group_id'


end
