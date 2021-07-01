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

  scope :within, lambda { |time|
    where('created_at >= ?', time.ago)
  }

  # Click.group_by_time_ago
  # Purpose: Group the clicks by a specified time period
  #          and count the number of clicks over that period
  # Arguments:
  #   time   - a Duration object (e.g. 5.days)
  #   format - a string used to determine the grouping of the clicks.
  #            For instance, to group by day, the format string could
  #            be '%m/%d'
  def self.group_by_time_ago(time, format)
    duration_type = time.parts[0][0]
    # Initialize the return array
    click_counts = {}
    (0..time.parts[0][1] - 1).reverse_each do |time_ago|
      click_counts[time_ago.send(duration_type).ago.strftime(format)] = 0
    end

    all.within(time)
       .group("date_format(created_at, '%Y%m%d %H')")
       .count
       .each do |result|
      time_label = DateTime.parse(result[0])
                           .in_time_zone(Time.zone)
                           .strftime(format)

      if click_counts[time_label].nil?
        click_counts[time_label] = result[1]
      else
        click_counts[time_label] += result[1]
      end
    end

    click_counts
  end

  def self.max_by_day
    click_counts = {}

    all.group("date_format(created_at, '%Y%m%d %H')").count.each do |result|
      time_label = Date.parse(result[0])
      if click_counts[time_label].present?
        click_counts[time_label] += result[1]
      else
        click_counts[time_label] = result[1]
      end
    end
    click_counts.max_by { |_k, v| v }
  end
end
