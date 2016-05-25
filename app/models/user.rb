# == Schema Information
#
# Table name: users
#
#  id               :integer          not null, primary key
#  uid              :string(255)
#  context_group_id :integer
#  admin            :boolean
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class User < ApplicationRecord
  has_and_belongs_to_many :groups, join_table: :groups_users
  # this next bit of magic removes any associations in the group_users table
  before_destroy {|user| user.groups.clear}
  belongs_to :context_group, foreign_key: 'context_group_id', class_name: "Group"
  
  before_validation(on: :create) do
    self.context_group = Group.create(name: self.uid, description: self.uid) if self.context_group.blank?
    self.groups << self.context_group
  end
  
end
