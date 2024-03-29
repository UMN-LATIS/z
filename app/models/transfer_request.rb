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
  include VersionUser
  has_paper_trail
  before_save :pre_approve
  before_destroy :version_history
  after_save :version_history

  belongs_to :from_group, class_name: 'Group'
  belongs_to :to_group, class_name: 'Group'
  belongs_to :from_user, foreign_key: 'from_group_requestor_id', class_name: 'User'
  belongs_to :to_user, primary_key: 'default_group_id', foreign_key: 'to_group_id', class_name: 'User'

  has_and_belongs_to_many :urls,
                          join_table: :transfer_request_urls,
                          dependant: :destroy

  validate :from_user_must_own_urls_or_from_user_is_admin

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

  def version_history
    h = "<b> Requested By: #{from_user.internet_id} </b><br/>"
    h.concat "<b> To User: #{to_user.internet_id} </b><br/>"
    h.concat "<b> Current Status: #{status} </b><br/>"
    h.concat "<br/><b>URLs:</b><br/>"
    urls.each do |url|
      h.concat "<a href=\"#{url.url}\">#{url.keyword}</a><br/>"
    end
    h.concat "<h3>History</h3><hr>"
    versions.each do |v|
      g = v.reify # unless v.event.equal? "create"
      h.concat "<b>What Happened: </b> #{v.event} <br/>"
      h.concat "<b>Who Made It: </b>  #{self.class.version_user(v)}<br/>"
      h.concat "<b>Previous Status: </b>  #{g ? g.status : 'N/A'}<br/>"
      h.concat "<br/><br/>"
    end
    versions.each do |v|
      v.version_history = h
      v.save
    end
  end
end
