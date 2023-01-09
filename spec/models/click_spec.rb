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

    describe('.max_by_day') do
      it 'shows the best day and number of clicks' do
        # all clicks
        expect(described_class.max_by_day).to eq([Time.zone.now.utc.to_date, 101])
        # clicks specific to a url
        expect(url1.clicks.max_by_day).to eq([(Time.zone.now.utc - 2.days).to_date, 3])
      end
    end
  end
end
