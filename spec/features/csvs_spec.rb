require 'rails_helper'

describe 'getting csv of clicks for url(s) clicked yesterday and two days ago' do
  let(:keyword) { 'testkeyword' }
  let(:url) { 'http://www.google.com' }
  let(:created_at) { Time.now - 1.day }

  let(:keyword2) { 'testkeyword2' }
  let(:url2) { 'http://www.google2.com' }
  let(:created_at2) { Time.now - 1.day }

  before do
    @user = FactoryBot.create(:user)
    sign_in(@user)

    @url = FactoryBot.create(
      :url,
      group: @user.context_group,
      keyword: keyword,
      url: url,
      created_at: created_at
    )
    @url2 = FactoryBot.create(
      :url,
      group: @user.context_group,
      keyword: keyword2,
      url: url2,
      created_at: created_at2
    )
    # add 10 clicks to yesterday for first url
    10.times do
      @url.clicks << Click.create(
        country_code: 'US',
        created_at: Time.now - 1.day
      )
      @url.total_clicks += 1
      @url.save
    end
    # add 5 clicks to yesterday for second url
    5.times do
      @url2.clicks << Click.create(
        country_code: 'US',
        created_at: Time.now - 2.days
      )
      @url2.total_clicks += 1
      @url2.save
    end
  end

  describe 'for 1 url' do
    before do
      # get yesterday's csv
      @urls = [@url]
      @csv = CSV.new(Url.to_csv('2', 'days', @urls))
      @header_row = @csv.shift
      @data_row = @csv.shift
    end
    it 'should have two rows a header and data for one url' do
      expect(CSV.parse(Url.to_csv('2', 'days', @urls)).size).to match(2)
    end
    it 'should have column name url in first cell, first row' do
      expect(@header_row[0]).to match('url')
    end
    it 'should have column name keyword in second cell, first row' do
      expect(@header_row[1]).to match('keyword')
    end
  end
  describe 'for 2 urls, two days' do
    before do
      # get yesterday's and two days ago csv
      @urls = [@url, @url2]
      @csv = CSV.new(Url.to_csv('3', 'days', @urls))
      @header_row = @csv.shift
      @yesterday = @csv.shift
      @two_days_ago = @csv.shift
    end
    it 'should have three rows a header and 2 riws data for 2 url' do
      expect(CSV.parse(Url.to_csv('2', 'days', @urls)).size).to match(3)
    end
    it 'should have column name url in first cell, first row' do
      expect(@header_row[0]).to match('url')
    end
    it 'should have column name keyword in second cell, first row' do
      expect(@header_row[1]).to match('keyword')
    end
  end
end
