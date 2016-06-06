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

  validates :url, presence: true, format:
    { with: /\A#{URI.regexp(%w(http https))}\z/ }

  before_validation(on: :create) do
    # Set clicks to zero
    self.total_clicks = 0
  end

  before_validation do
    # Set keyword if it's blank
    if keyword.blank?
      index = Url.maximum(:id).to_i.next
      index += 1 while Url.exists?(keyword: index.to_s(36))
      self.keyword = index.to_s(36)
    end

    # Strip URL of any invalid characters, only allow alphanumeric
    self.keyword = keyword.gsub(/[^0-9a-z\\s]/i, '')
  end

  def add_click!
    clicks << Click.create(country_code: 'US')
    self.total_clicks = total_clicks + 1
    save
  end
end
