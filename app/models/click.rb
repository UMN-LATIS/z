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

  scope :within, lambda { |duration_ago|
    where('created_at >= ?', duration_ago.ago)
  }

  ##
  # Purpose: Group the clicks by a specified duration
  #          and count the number of clicks over that duration
  # Arguments:
  #   duration_ago - a Duration object (e.g. 5.days)
  #   format - a string used to determine the grouping of the clicks.
  #            For instance, to group by day, the format string could
  #            be '%m/%d'
  # Returns: a hash of the form { formatted time string => count }
  ##
  def self.group_by_time_ago(duration, format)
    clicks_hash = all.within(duration)
                     .group("date_format(created_at, '%Y%m%d %H')")
                     .count
                     .each_with_object({}) do |(datetime, count), acc|
      time_label = Time.zone.parse(datetime).strftime(format)

      # if label not in use, count is nil so cast nil to 0 for previous count
      prev_count = acc[time_label].to_i
      acc[time_label] = prev_count + count
    end

    # sorted by datetime
    clicks_hash.sort_by { |datetime, _clicks| Time.zone.parse(datetime) }.to_h
  end

  # Group clicks over a duration by hour or day, returning ISO 8601 UTC
  # timestamps as keys. Formatting moves to the client.
  #
  # @param duration [ActiveSupport::Duration] how far back to look
  # @param interval [Symbol] :hour (default) or :day
  # @return [Hash{String => Integer}] { iso_utc_string => count }
  def self.group_by_time_ago_utc(duration, interval: :hour)
    format_str = case interval
                 when :hour then '%Y%m%d %H'
                 when :day then '%Y%m%d'
                 else raise ArgumentError, "unknown interval #{interval.inspect}"
                 end

    all.within(duration)
       .group("date_format(created_at, '#{format_str}')")
       .count
       .each_with_object({}) do |(datetime, count), acc|
      utc_time = Time.utc(
        datetime[0..3].to_i,   # year
        datetime[4..5].to_i,   # month
        datetime[6..7].to_i,   # day
        interval == :hour ? datetime[9..10].to_i : 0
      )
      iso_key = utc_time.iso8601

      prev_count = acc[iso_key].to_i
      acc[iso_key] = prev_count + count
    end.sort_by { |iso, _| Time.iso8601(iso) }.to_h
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
