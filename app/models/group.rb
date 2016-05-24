class Group < ApplicationRecord
  has_and_belongs_to_many :users, join_table: GroupsUser

  
end
