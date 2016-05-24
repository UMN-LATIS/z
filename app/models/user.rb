class User < ApplicationRecord
  has_and_belongs_to_many :groups, join_table: GroupsUser
  belongs_to :group, foreign_key: 'context_group_id'


end
