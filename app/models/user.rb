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
  before_destroy { |user| user.groups.clear }
  belongs_to :context_group,
             foreign_key: 'context_group_id',
             class_name: 'Group'

  before_validation(on: :create) do
    self.context_group =
      Group.create(name: uid, description: uid) if context_group.blank?
    groups << context_group
  end

  before_save { generate_token(:remember_token) }

  private

  def generate_token(column)
    loop do
      self[column] = SecureRandom.urlsafe_base64
      break unless User.exists?(column => self[column])
    end
  end
end
