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
# FORCE INDEX note: the analytics methods below use FORCE INDEX to make
# MySQL use the (url_id, created_at) composite. Without the hint, the query
# planner sometimes picks (url_id, country_code) instead because it estimates
# the same row count for both. The created_at index is the right choice here
# because it gives us rows pre-sorted by time, turning the WHERE clause into
# a range scan instead of a full partition scan. On a 7M-click URL this is
# the difference between ~46s and ~2s on a 5-year daily query.
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

  # Count clicks in each hour over the given duration, keyed by ISO 8601 UTC
  # timestamp. Only hours with at least one click are included.
  #
  # Intended for narrow time windows (24 hours, 7 days, 30 days) where the
  # client wants to display hour-level bars or bucket into local days. For
  # longer ranges, prefer #daily_counts.
  #
  # @param duration [ActiveSupport::Duration] how far back to look
  # @return [Hash{String => Integer}] { "2026-04-10T15:00:00Z" => count }
  def self.hourly_counts(duration)
    all.from('clicks FORCE INDEX (index_clicks_on_url_id_and_created_at)')
       .within(duration)
       .group("DATE_FORMAT(created_at, '%Y-%m-%dT%H:00:00Z')")
       .count
  end

  # Count clicks in each day over the given duration, keyed by ISO 8601 UTC
  # date. Only days with at least one click are included.
  #
  # Uses MySQL's native DATE() function — much faster than DATE_FORMAT() for
  # day-level grouping over large ranges. On a 7M-click URL the 5-year query
  # runs in ~2s with the composite index (vs ~48s before the index).
  #
  # Intended for wider time windows (year, 5 years) where the client wants
  # to display monthly bars rolled up from daily data, or compute the
  # best day.
  #
  # @param duration [ActiveSupport::Duration] how far back to look
  # @return [Hash{String => Integer}] { "2026-04-10" => count }
  def self.daily_counts(duration)
    all.from('clicks FORCE INDEX (index_clicks_on_url_id_and_created_at)')
       .within(duration)
       .group('DATE(created_at)')
       .count
       .transform_keys(&:to_s)
  end
end
