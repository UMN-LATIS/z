# == Schema Information
#
# Table name: clicks
#
#  id           :integer          not null, primary key
#  country_code :string(255)
#  url_id       :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class Click < ApplicationRecord
  belongs_to :url

  scope :within_hours, ->(hours_ago) do
    where('created_at >= ?', hours_ago.hours.ago)
  end

  scope :within_days, ->(days_ago) do
    where('created_at >= ?', days_ago.days.ago)
  end

  def self.group_by_hour_new(last=24)
    # Initialize the return array
    click_counts = {}
    (0..last-1).reverse_each do |hour_ago|
      click_counts[hour_ago.hours.ago.strftime("%I:00 %p")] = 0
    end

    all.within_hours(last).group("date_format(created_at, '%Y%m%d %H')").count.each do |result|
      click_counts[DateTime.parse(result[0]).in_time_zone(Time.zone).strftime("%I:00 %p")] = result[1]
    end

    click_counts
  end

  def self.group_by_day_new(last=30)
    # Initialize the return array
    click_counts = {}
    (0..last-1).reverse_each do |days_ago|
      click_counts[days_ago.days.ago.strftime("%m/%d")] = 0
    end

    all.within_days(last).group("date_format(created_at, '%Y%m%d %H')").count.each do |result|
      click_counts[DateTime.parse(result[0]).in_time_zone(Time.zone).strftime("%m/%d")] += result[1]
    end

    click_counts
  end
end
