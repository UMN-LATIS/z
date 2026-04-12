# frozen_string_literal: true

require 'rails_helper'

def repeatedly_click(url: nil, days_ago: 0, times: 10)
  url ||= FactoryBot.create(:url)
  times.times do
    Click.create(url_id: url.id, country_code: 'US', created_at: days_ago.days.ago)
  end
end

RSpec.describe Click, type: :model do
  subject(:click) do
    url = FactoryBot.create(:url)
    described_class.new(
      url_id: url.id,
      country_code: 'US'
    )
  end

  it { is_expected.to be_valid }
  it { is_expected.to be_a(described_class) }
  it { is_expected.to belong_to(:url) }

  it 'is invalid without a url' do
    click.url_id = nil
    expect(click).not_to be_valid
  end

  describe('click summaries') do
    let(:url1) { FactoryBot.create(:url) }
    let(:url2) { FactoryBot.create(:url) }

    before do
      repeatedly_click(url: url1, times: 1, days_ago: 0)
      repeatedly_click(url: url1, times: 2, days_ago: 1)
      repeatedly_click(url: url1, times: 3, days_ago: 2)
      repeatedly_click(url: url2, times: 100, days_ago: 0)
    end

    describe('.group_by_time_ago') do
      year_month_day_strf = '%Y-%m-%d'

      # this feels like word salad
      it 'counts url clicks over a given duration, returning a hash keyed by a given time format string' do
        expect(url1.clicks.group_by_time_ago(3.days, year_month_day_strf))
          .to eq({
                   2.days.ago.utc.strftime(year_month_day_strf) => 3,
                   1.day.ago.utc.strftime(year_month_day_strf) => 2,
                   Time.zone.now.utc.strftime(year_month_day_strf) => 1
                 })

        expect(url2.clicks.group_by_time_ago(3.days, year_month_day_strf))
          .to eq({
                   Time.zone.now.utc.strftime(year_month_day_strf) => 100
                 })

        # total clicks
        expect(described_class.group_by_time_ago(3.days, year_month_day_strf))
          .to eq({
                   2.days.ago.utc.strftime(year_month_day_strf) => 3,
                   1.day.ago.utc.strftime(year_month_day_strf) => 2,
                   Time.zone.now.utc.strftime(year_month_day_strf) => 101
                 })
      end

      it 'is sorted by oldest to most current dates' do
        # add new clicks, but pretend they're older
        repeatedly_click(url: url1, times: 1, days_ago: 7)
        clicks_by_day_hash = url1.clicks.group_by_time_ago(10.days, year_month_day_strf)
        expect(clicks_by_day_hash.to_a)
          .to eq([
                   [7.days.ago.utc.strftime(year_month_day_strf), 1],
                   [2.days.ago.utc.strftime(year_month_day_strf), 3],
                   [1.day.ago.utc.strftime(year_month_day_strf), 2],
                   [Time.zone.now.utc.strftime(year_month_day_strf), 1]
                 ])
      end
    end

    describe('.hourly_counts') do
      it 'returns a hash keyed by ISO 8601 UTC timestamps with click counts' do
        result = url1.clicks.hourly_counts(3.days)

        # all keys should be parseable ISO 8601 UTC timestamps
        result.each_key do |key|
          time = Time.iso8601(key)
          expect(time.utc?).to be(true), "Expected #{key} to be a UTC timestamp"
        end

        # counts should match what group_by_time_ago returns
        expect(result.values.sum).to eq(6) # 1 + 2 + 3 clicks for url1
      end

      it 'returns timestamps at hourly granularity' do
        result = url1.clicks.hourly_counts(3.days)

        result.each_key do |key|
          time = Time.iso8601(key)
          expect(time.min).to eq(0), "Expected #{key} to have 0 minutes (hourly bucket)"
          expect(time.sec).to eq(0), "Expected #{key} to have 0 seconds (hourly bucket)"
        end
      end

      it 'aggregates multiple clicks in the same hour' do
        fresh_url = FactoryBot.create(:url)
        target_hour = Time.zone.now.utc.beginning_of_hour
        5.times do
          Click.create!(url_id: fresh_url.id, country_code: 'US', created_at: target_hour + 5.minutes)
        end

        result = fresh_url.clicks.hourly_counts(1.day)
        expect(result[target_hour.iso8601]).to eq(5)
      end
    end

    describe('.daily_counts') do
      it 'returns a hash keyed by ISO 8601 UTC date strings with click counts' do
        result = url1.clicks.daily_counts(3.days)

        result.each_key do |key|
          expect(key).to match(/\A\d{4}-\d{2}-\d{2}\z/)
        end
        expect(result.values.sum).to eq(6) # 1 + 2 + 3 clicks for url1
      end

      it 'aggregates clicks occurring on the same UTC day' do
        fresh_url = FactoryBot.create(:url)
        target_day = Time.zone.now.utc.beginning_of_day
        5.times do
          Click.create!(url_id: fresh_url.id, country_code: 'US', created_at: target_day + 3.hours)
        end
        2.times do
          Click.create!(url_id: fresh_url.id, country_code: 'US', created_at: target_day + 20.hours)
        end

        result = fresh_url.clicks.daily_counts(1.day)
        expect(result[target_day.to_date.to_s]).to eq(7)
      end

      it 'excludes clicks outside the duration window' do
        repeatedly_click(url: url1, times: 4, days_ago: 10)
        result = url1.clicks.daily_counts(3.days)
        expect(result.values.sum).to eq(6) # the 10-days-ago clicks are excluded
      end
    end

  end
end
