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
  belongs_to :from_group, foreign_key: 'from_group_id', class_name: 'Group'
  belongs_to :to_group, foreign_key: 'to_group_id', class_name: 'Group'

  has_and_belongs_to_many :urls,
                          join_table: :transfer_request_urls,
                          dependant: :destroy

  validate :from_group_must_own_urls

  def from_group_must_own_urls
    from_group_urls_length =
      urls.map(&:group_id).count(from_group_id)
    num_urls = urls.length

    unless num_urls == from_group_urls_length || from_group.try(:admin?)
      errors.add(:from_group, 'must own URLs')
    end
  end

  def approve!
    urls.each do |url|
      url.group_id = to_group_id
      url.save
    end
    destroy
    destroyed?
  end

  def reject!
    destroy
    destroyed?
  end
end
