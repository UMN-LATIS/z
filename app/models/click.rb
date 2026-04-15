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

  # { "2026-04-10T15:00:00Z" => count } — hours with zero clicks omitted.
  # DATE + HOUR beats DATE_FORMAT by ~5x on large scans; ISO key stitched in Ruby.
  def self.hourly_counts(duration)
    aggregate_counts(duration, 'DATE(created_at)', 'HOUR(created_at)')
      .transform_keys { |(date, hour)| format('%sT%02d:00:00Z', date, hour) }
  end

  # { "2026-04-10" => count } — days with zero clicks omitted.
  def self.daily_counts(duration)
    aggregate_counts(duration, 'DATE(created_at)').transform_keys(&:to_s)
  end

  def self.aggregate_counts(duration, *grouping)
		# FORCE INDEX to ensure query uses index for better perf
		# difference is ~33s vs ~34ms on 5M-click url
    all.from('clicks FORCE INDEX (index_clicks_on_url_id_and_created_at)')
       .within(duration)
       .group(*grouping)
       .count
  rescue ActiveRecord::StatementInvalid => e
		# handle case where index is missing
		# this shouldn't happen prod unless we rollback
		# and need to rebuild the old index
    raise unless e.message.include?('index_clicks_on_url_id_and_created_at')

    all.within(duration).group(*grouping).count
  end
  private_class_method :aggregate_counts
end
