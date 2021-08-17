# frozen-string-literal: true

require 'rails_helper'

describe 'zlink stats page', js: true do
  let(:keyword) { 'testkeyword' }
  let(:url) { 'http://www.google.com' }
  let(:created_at) { Time.zone.now - 1.day }

  before do
    @user = FactoryBot.create(:user)
    sign_in(@user)
    wait_for_ajax

    @url = FactoryBot.create(
      :url,
      group: @user.context_group,
      keyword: keyword,
      url: url,
      created_at: created_at
    )
    # add 10 clicks to yesterday
    10.times do
      @url.clicks << Click.create(
        country_code: 'US',
        created_at: Time.zone.now - 1.day
      )
      @url.total_clicks += 1
      @url.save
    end

    # add 5 clicks to today
    5.times do
      @url.clicks << Click.create(
        country_code: 'US',
        created_at: Time.zone.now
      )
      @url.total_clicks += 1
      @url.save
    end

    visit url_path(@url.keyword)
  end

  it 'displays long url' do
    expect(page).to have_content url
  end

  it 'displays the keyword' do
    expect(page).to have_content keyword
  end

  it 'displays created date' do
    expect(page).to have_content created_at.to_s(:created_on_formatted)
  end

  it 'displays best day' do
    expect(page).to have_content '10 hits'
  end

  it 'displays the total clicks' do
    expect(page).to have_content '15 hits'
  end

  it 'displays the share to twitter button' do
    expect(page).to have_selector('.url-share-button-twitter')
  end

  it 'displays the download QR code button' do
    expect(page).to have_selector('.url-share-button-qr')
  end

  describe 'downloading qr code', js: true do
    before { find('.url-share-button-qr').click }

    it 'is a png type', retry: 3 do
      expect(page.status_code).to eq 200
      expect(page.response_headers['Content-Type']).to eq('image/png')
    end

    it 'is not blank' do
      expect(page.body).not_to be_blank
    end
  end

  describe 'collection dropdown' do
    before do
      @new_group = FactoryBot.create(:group)
      @new_group.users << @user
      sign_in(@user)
      wait_for_ajax
      visit url_path(@url.keyword)
      wait_for_ajax
      find('.bootstrap-select .dropdown-toggle').click
      accept_confirm do
        find('.dropdown-menu.open').find('li', text: @new_group.name).click
      end
      wait_for_ajax
    end

    it 'changes the collection' do
      expect(page).to have_selector('.bootstrap-select .dropdown-toggle', text: @new_group.name)
    end

    it 'updates the urls collection in the database' do
      @url.reload
      expect(@url.group.id).to eq(@new_group.id)
    end
  end
end
