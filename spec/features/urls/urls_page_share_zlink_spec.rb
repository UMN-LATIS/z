# frozen-string-literal: true

require 'rails_helper'

describe 'when sharing existing url', js: true do
  let(:user) { FactoryBot.create(:user) }
  let(:url) { FactoryBot.create(:url) }

  before do
    # set this url to be owned by the user
    url.update(group: user.context_group)

    sign_in(user)
    visit urls_path
  end

  it 'displays the share to twitter button' do
    expect(page).to have_selector('.dropdown .actions-dropdown-button')
    find('.dropdown .actions-dropdown-button').click
    find('.dropdown-menu .share-url').hover

    expect(page).to have_selector('.url-share-button-twitter')
  end

  it 'displays the download QR code button' do
    expect(page).to have_selector('.dropdown .actions-dropdown-button')
    find('.dropdown .actions-dropdown-button').click
    find('.dropdown-menu .share-url').hover

    expect(page).to have_selector('.url-share-button-qr')
  end

  it 'downloads a qr code' do
    expect(page).to have_selector('.dropdown .actions-dropdown-button')
    find('.dropdown .actions-dropdown-button').click
    find('.dropdown-menu .share-url').hover

    find('.url-share-button-qr').click
    expect(page.body).not_to be_blank
    expect(page.response_headers['Content-Type']).to eq('image/png')
  end
end
