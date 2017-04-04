# == Schema Information
#
# Table name: transfer_requests
#
#  id            :integer          not null, primary key
#  to_group_id   :integer
#  from_group_id :integer
#  key           :string(255)
#  status        :string(255)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class TransferRequest < ApplicationRecord
  has_paper_trail
  belongs_to :from_group, foreign_key: 'from_group_id', class_name: 'Group'
  belongs_to :to_group, foreign_key: 'to_group_id', class_name: 'Group'
  belongs_to :from_user, foreign_key: 'from_group_requestor_id', class_name: 'User'
  belongs_to :to_user, primary_key: 'default_group_id', foreign_key: 'to_group_id', class_name: 'User'

  has_and_belongs_to_many :urls,
                          join_table: :transfer_request_urls,
                          dependant: :destroy

  validate :from_user_must_own_urls_or_from_user_is_admin

  before_save :pre_approve

  scope :pending, -> { where(status: 'pending') }

  def pre_approve
    if from_user.admin?
      # as an admin, do not rubberstamp if I belong to at least one url's group in this request
      return if urls.any? { |url| url.group.user?(from_user) }
    else
      # as a non-admin, do not rubberstamp unless I am in the group I want to transfer to or am transferring to myself
      return unless from_user.in_group?(to_group) || from_user == to_user
    end
    approve
  end

  def from_user_must_own_urls_or_from_user_is_admin
    url_groups = urls.map(&:group_id)
    user_groups = from_user.groups.pluck(:id)
    return if (url_groups - user_groups).empty? || from_group.try(:admin?) || from_user.try(:admin?)
    errors.add(:from_user, 'must own URLs')
  end

  def approve
    Url.where(id: urls.map(&:id)).update_all(group_id: to_group_id)
    self.status = 'approved'
  end

  def reject
    self.status = 'rejected'
  end

  def approve!
    approve
    save
  end

  def reject!
    reject
    save
  end

end
