# frozen-string-literal: true

require 'rails_helper'

describe 'zlink stats page' do
  let(:created_at) { Time.zone.now - 1.day }
  let(:user) { FactoryBot.create(:user) }
  let(:url) do
    FactoryBot.create(
      :url,
      group: user.context_group,
      keyword: 'g',
      url: 'http//www.google.com',
      created_at: created_at
    )
  end

  before do
    sign_in user
  end

  context 'when given a url that does not exist' do
    it 'shows not found page' do
      visit url_path('doesnotexist')
      expect(page).to have_content('Not Found')
    end
  end

  context 'when given a url that exists', js: true do
    before do
      # add 10 clicks to yesterday
      10.times do
        url.clicks << Click.create(
          country_code: 'US',
          created_at: Time.zone.now - 1.day
        )
        url.total_clicks += 1
        url.save
      end

      # add 5 clicks to today
      5.times do
        url.clicks << Click.create(
          country_code: 'US',
          created_at: Time.zone.now
        )
        url.total_clicks += 1
        url.save
      end

      visit url_path(url.keyword)
    end

    it 'displays long url' do
      expect(page).to have_content url.url
    end

    it 'displays the keyword' do
      expect(page).to have_content url.keyword
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
      let(:new_group) { FactoryBot.create(:group) }

      before do
        new_group.users << user
        visit url_path(url.keyword)
        find('.bootstrap-select .dropdown-toggle').click
        accept_confirm do
          find('.dropdown-menu.open').find('li', text: new_group.name).click
        end
      end

      it 'changes the collection' do
        expect(page).to have_selector('.bootstrap-select .dropdown-toggle', text: new_group.name)
      end

      it 'updates the urls collection in the database' do
        url.reload
        expect(url.group.id).to eq(new_group.id)
      end
    end
  end
end
