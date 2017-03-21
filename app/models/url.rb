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
require 'uri'
class Url < ApplicationRecord
  has_paper_trail :ignore => [:total_clicks]

  belongs_to :group
  has_many :clicks, dependent: :destroy
  has_and_belongs_to_many :transfer_requests, join_table: :transfer_request_urls

  # this next bit of magic removes any associations in the transfer_request_urls
  # table
  before_destroy { |url| url.transfer_requests.clear }

  before_save do
    # Add http:// if necessary
    self.url = "http://#{url}" if URI.parse(url).scheme.nil?
  end

  validates :keyword, uniqueness: true, presence: true
  validates :url, presence: true
  validates :keyword, format: {
                        with: /^[a-zA-Z0-9\-_]*$/,
                        multiline: true,
                        message: 'special characters are not permitted. Only letters, and numbers, dashes ("-") and underscores ("_")'
                    }
  validates :keyword, length: { in: 1..25 }
  validate :check_for_valid_url

  before_validation(on: :create) do
    # Set clicks to zero
    self.total_clicks = 0
  end

  before_validation do
    # remove leading and trailing whitespaces for validation
    url.strip!

    # Set keyword if it's blank
    if keyword.blank?
      index = Url.maximum(:id).to_i.next
      index += 1 while Url.exists?(keyword: index.to_s(36))
      self.keyword = index.to_s(36)
    end

    # Downcase the keyword
    self.keyword = keyword.downcase
    #    else
  end

  scope :created_by_id, ->(group_id) do
    where('group_id = ?', group_id)
  end

  scope :created_by_ids, ->(group_ids) do
    where('group_id IN (?)', group_ids)
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

  scope :not_in_pending_transfer_request, -> do
    url_ids = TransferRequest.pending.joins(:urls).pluck(:url_id)
    where.not("#{table_name}.id IN (?)", url_ids) if url_ids.present?
  end

  def add_click!(location)
    clicks << Click.create(country_code: location.try(:country_code))
    self.total_clicks = total_clicks + 1
    save
  end

  def click_data_to_csv
    # ex: http://localhost:3000/shortener/urls/3/csv/raw.csv
    data = CSV.generate(headers: true) do |csv|
      clicks.select(:country_code, :created_at).each do |click|
        csv << [url, keyword, click.country_code, click.created_at.to_s(:created_on_formatted)]
      end
    end
    return %w{url keyword country_code url_created_on}.to_csv + data
  end

  def self.to_csv(duration, time_unit, urls)
    # ex: http://localhost:3000/shortener/urls/csv/24/days.csv
    col_names = nil
    formats = {days: '%m/%d', hours: '%I:%M%p'}
    data = CSV.generate(headers: true) do |csv|
      urls.each do |url|
        res = url.clicks.group_by_time_ago(duration.to_i.send(time_unit), formats[time_unit.to_sym])
        col_names = %w{url keyword} + res.keys
        col_values = [url.url, url.keyword] + res.values
        csv << col_values
      end
    end
    return col_names.to_csv + data
  end

  def check_for_valid_url
    begin
      URI.parse(url)
    rescue URI::InvalidURIError
      errors.add(:url, 'is not valid.')
    end
  end

end
