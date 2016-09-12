# == Schema Information
#
# Table name: urls
#
#  id           :integer          not null, primary key
#  url          :string(255)
#  keyword      :string(255)
#  total_clicks :integer
#  group_id     :integer
#  modified_by  :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
class Url < ApplicationRecord
  belongs_to :group
  has_many :clicks, dependent: :destroy
  has_and_belongs_to_many :transfer_requests, join_table: :transfer_request_urls

  # this next bit of magic removes any associations in the transfer_request_urls
  # table
  before_destroy { |url| url.transfer_requests.clear }

  validates :keyword, uniqueness: true, presence: true

  validates :url, presence: true

  before_validation(on: :create) do
    # Set clicks to zero
    self.total_clicks = 0
  end

  before_validation do
    # Add http:// if necessary
    unless url =~ /\A#{URI.regexp(%w(http https))}\z/ || url.blank?
      self.url = "http://#{url}"
    end

    # Set keyword if it's blank
    if keyword.blank?
      index = Url.maximum(:id).to_i.next
      index += 1 while Url.exists?(keyword: index.to_s(36))
      self.keyword = index.to_s(36)
    end

    # Downcase the keyword
    self.keyword = keyword.downcase

    # Strip URL of any invalid characters, only allow alphanumeric
    self.keyword = keyword.gsub(/[^0-9a-z\\s]/i, '')
  end

  scope :created_by_id, ->(group_id) do
    where('group_id = ?', group_id)
  end

  scope :created_by_name, ->(group_name) do
    owner_to_search = "%#{group_name}%"
    possible_groups = Group.where('name LIKE ?', owner_to_search).map(&:id)
    where('group_id IN (?)', possible_groups)
  end

  scope :by_keyword, ->(keyword) do
    where('keyword LIKE ?', "%#{keyword.try(:downcase)}%")
  end

  scope :by_keywords, ->(keywords) do
    where('keyword IN (?)', "%#{keywords.map(&:downcase)}%")
  end

  scope :not_in_transfer_request, ->(transfer_request) do
    url_ids = transfer_request.urls.pluck(:id)
    where.not('id IN (?)', url_ids) if url_ids.present?
  end

  scope :not_in_any_transfer_request, -> do
    url_ids = TransferRequestUrl.all.pluck(:url_id)
    where.not('id IN (?)', url_ids) if url_ids.present?
  end

  def add_click!
    clicks << Click.create(country_code: 'US')
    self.total_clicks = total_clicks + 1
    save
  end
end
