# == Schema Information
#
# Table name: groups
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  description :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# models/group.rb
class Group < ApplicationRecord
  has_many :groups_users, dependent: :destroy
  has_many :users, through: :groups_users
  has_many :urls, dependent: :destroy

  has_many :user_contexts, foreign_key: :context_group_id, class_name: 'User'

  validates :name, presence: true

  # When a group is destroyed, be sure to reset everyone's contex
  # to their defaults
  before_destroy do |group|
    User.where(context_group_id: group.id).find_each(&:reset_context!)
  end

  def user?(user)
    users.exists?(user.id)
  end

  def add_user(user, send_group_change_notifications = false)
    users << user unless users.exists?(user.id)
    groups_users.find_by_user_id(user).update(
      notify_user_changes: send_group_change_notifications
    )
  end

  def remove_user(user)
    users.delete(user)
  end

  # Groups for admins will only be one person long and the only user
  # will be an administrator
  def admin?
    users.length == 1 && users.first.admin?
  end

  #all groups that arent the default group for a user
  def self.all_that_arent_default
    Group.where("id not in ( select default_group_id from users)")
  end
end
