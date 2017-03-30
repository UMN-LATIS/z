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

  validate :from_group_must_own_urls

  before_save :pre_approve

  scope :pending, -> { where(status: 'pending') }

  def pre_approve
    return unless pre_approve?
    approve
  end

  def from_group_must_own_urls
    from_group_urls_length =
        urls.map(&:group_id).count(from_group_id)
    num_urls = urls.length
    return if num_urls == from_group_urls_length || from_group.try(:admin?)
    errors.add(:from_group, 'must own URLs')
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

  private

  def pre_approve?
    from_user.in_group?(to_group) || to_user == from_user
  end
end
