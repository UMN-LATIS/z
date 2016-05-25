# == Schema Information
#
# Table name: groups_users
#
#  group_id            :integer
#  user_id             :integer
#  notify_user_changes :boolean          default(FALSE)
#

class GroupsUser < ApplicationRecord
  belongs_to :group
  belongs_to :user
end
