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
require 'ipaddr'

class Url < ApplicationRecord
  include VersionUser
  has_paper_trail ignore: [:total_clicks]
  before_destroy :version_history
  after_save :version_history

  belongs_to :group
  has_many :clicks, dependent: :delete_all
  has_and_belongs_to_many :transfer_requests, join_table: :transfer_request_urls

  # this next bit of magic removes any associations in the transfer_request_urls
  # table
  before_destroy { |url| url.transfer_requests.clear }

  before_save do
    # Add http:// if necessary
    self.url = "http://#{url}" if URI.parse(url).scheme.nil?
  end

  validates :keyword, uniqueness: { case_sensitive: false }, presence: true
  validates :url, presence: true
  validates :keyword, format: {
    with: /^[a-zA-Z0-9\-_]*$/,
    multiline: true,
    message: 'special characters are not permitted. Only letters, and numbers, dashes ("-") and underscores ("_")'
  }
  validates :notes, length: { maximum: 1000 }, allow_blank: true
  validate :check_for_valid_url

  before_validation do
    # remove leading and trailing whitespaces for validation
    url.strip!

    # Set keyword if it's blank
    if keyword.blank?
      index = Url.maximum(:id).to_i.next
      index += 1 while Url.exists?(keyword: index.to_s(36))
      self.keyword = index.to_s(36)
    end
  end

  scope :created_by_id, lambda { |group_id|
    where(group_id: group_id)
  }

  scope :created_by_ids, lambda { |group_ids|
    where(group_id: group_ids)
  }

  scope :created_by_name, lambda { |group_name|
    owner_to_search = "%#{group_name}%"
    possible_groups = Group.where('name LIKE ?', owner_to_search).map(&:id)
    where(group_id: possible_groups)
  }

  scope :by_keyword, lambda { |keyword|
    where('keyword LIKE ?', "%#{keyword.try(:downcase)}%")
  }

  scope :by_keywords, lambda { |keywords|
    where(keyword: "%#{keywords.map(&:downcase)}%")
  }

  scope :not_in_pending_transfer_request, lambda {
    url_ids = TransferRequest.pending.joins(:urls).pluck(:url_id)
    where.not("#{table_name}.id IN (?)", url_ids) if url_ids.present?
  }

  def add_click!(client_ip)
    client_ip_decimal = IPAddr.new(client_ip).to_i

    begin
      @location = IpLocation.where('? >= ip_from AND ? < ip_to', client_ip_decimal, client_ip_decimal)

      country_code = @location.first!.country_code if @location.first!.country_code
    rescue StandardError
      country_code = ''
    end

    Click.create(country_code: country_code, url_id: id)
    update_columns(total_clicks: total_clicks + 1)
  end

  def click_data_to_csv
    # ex: http://localhost:3000/shortener/urls/3/csv/raw.csv
    data = CSV.generate(headers: true) do |csv|
      clicks.select(:country_code, :created_at).each do |click|
        csv << [url, keyword, click.country_code, click.created_at.to_fs(:created_on_formatted)]
      end
    end
    %w[url keyword country_code url_created_on].to_csv + data
  end

  def self.to_csv(duration, time_unit, urls)
    # ex: http://localhost:3000/shortener/urls/csv/24/days.csv
    col_names = %w[url keyword]
    formats = { days: '%m/%d', hours: '%I:%M%p' }
    data = CSV.generate(headers: true) do |csv|
      urls.each do |url|
        res = url.clicks.group_by_time_ago(duration.to_i.send(time_unit), formats[time_unit.to_sym])
        col_names += res.keys
        col_values = [url.url, url.keyword] + res.values
        csv << col_values
      end
    end
    col_names.to_csv + data
  end

  def check_for_valid_url
    URI.parse(url)
  rescue URI::InvalidURIError
    errors.add(:url, 'is not valid.')
  end

  def version_history
    h = "<b> Current URL: #{url} </b><br/>"
    h.concat "<b>Current Keyword: #{keyword}</b><br/>"
    h.concat "<b>Current Group: #{group.name}</b><br/>"
    h.concat "<h3>History</h3><hr>"
    versions.each do |v|
      g = v.reify unless v.event.equal? "create"
      h.concat "<b>What Happened: </b> #{v.event} <br/>"
      h.concat "<b>Who Made It: </b>  #{self.class.version_user(v)}<br/>"
      h.concat "<b>Previous URL: </b>  #{g ? g.url : 'N/A'}<br/>"
      h.concat "<b>Previous Keyword: </b>  #{g ? g.keyword : 'N/A'}<br/>"
      h.concat "<b>Previous Group Name: </b>  #{g && g.group ? g.group.name : 'N/A(Group doesnt exist)'}<br/>"
      h.concat "<b>Date of Change: </b>  #{g ? g.updated_at : 'N/A'}<br/>"
      h.concat "<br/><br/>"
    end
    versions.each do |v|
      v.version_history = h
      v.save
    end
  end
end
