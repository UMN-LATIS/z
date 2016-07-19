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
  # has_and_belongs_to_many :groups, join_table: :groups_users
  has_many :groups_users
  has_many :groups, through: :groups_users
  # this next bit of magic removes any associations in the group_users table
  before_destroy { |user| user.groups.clear }
  belongs_to :context_group,
             foreign_key: 'context_group_id',
             class_name: 'Group'
  validates :context_group, presence: true
  validate :user_belongs_to_context_group_validation

  before_validation(on: :create) do
    if context_group.blank?
      new_context = Group.create(
        name: uid,
        description: uid
      )
      groups << new_context
      self.context_group = new_context
    end
  end

  before_save { generate_token(:remember_token) }

  def in_group?(group)
    group.has_user?(self)
  end

  def update_context_group(group)
    self.context_group = group
  end

  def update_context_group!(group)
    update_context_group(group)
    save
  end

  private

  def user_belongs_to_context_group_validation
    unless in_group?(context_group) || context_group.nil? || new_record?
      errors.add(
        :context_group,
        "#{uid} is not a member of #{context_group.name}: #{context_group.description} and so cannot switch contexts to it."
      )
    end
  end

  def generate_token(column)
    loop do
      self[column] = SecureRandom.urlsafe_base64
      break unless User.exists?(column => self[column])
    end
  end
end
