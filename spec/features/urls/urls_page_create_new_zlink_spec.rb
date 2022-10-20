# frozen-string-literal: true

require 'rails_helper'

describe 'urls index page: creating new zlink', js: true do
  let(:user) { FactoryBot.create(:user) }
  let(:url) do
    'http://www.gggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg.com'
  end
  let(:keyword) { 'goog' }

  before do
    sign_in(user)
  end

  it 'shortens a url blurb that is super long' do
    visit urls_path
    find('.js-new-url-url').set url
    find('.js-new-url-keyword').set keyword

    find('.js-url-submit').click
    expect(page).to have_content('gggg...')
  end

  it 'shortens a camelCaseKeyword' do
    visit urls_path
    find('.js-new-url-url').set url
    find('.js-new-url-keyword').set 'aCamelCaseKeyword'
    find('.js-url-submit').click

    expect(page).to have_content('aCamelCaseKeyword')
    # it does not lower the case
    expect(page).not_to have_content('acamelcasekeyword')
  end

  it 'does not have active pagination buttons if there is only 1 url' do
    visit urls_path
    find('.js-new-url-url').set url
    find('.js-new-url-keyword').set keyword
    find('.js-url-submit').click

    expect(page).to have_selector('.paginate_button.next.disabled')
    expect(page).to have_selector('.paginate_button.previous.disabled')
  end

  it 'saves new urls upon clicking create' do
    visit urls_path
    find('.js-new-url-url').set url
    find('.js-new-url-keyword').set keyword
    expect do
      find('.js-url-submit').click
    end.to change(Url, :count).by(1)
  end

  it 'shows url sharing info (url blurb) after creating' do
    visit urls_path
    find('.js-new-url-url').set url
    find('.js-new-url-keyword').set keyword
    find('.js-url-submit').click

    expect(page).to have_selector('.url-blurb')
    expect(page.find(".url-blurb-source")).to have_content('gggg...')
    expect(page.find(".url-blurb-short-url")).to have_content(keyword)

    # share buttons
    expect(page).to have_selector('.url-blurb .url-share-button-twitter')
    expect(page).to have_selector('.url-blurb .url-share-button-qr')
  end

  it 'downloads a qr code' do
    visit urls_path
    find('.js-new-url-url').set url
    find('.js-new-url-keyword').set keyword
    find('.js-url-submit').click
    find('.url-share-button-qr').click

    expect(page.response_headers['Content-Type']).to eq('image/png')
    expect(page.body).not_to be_blank
  end

  it 'does not save URL if its invalid' do
    visit urls_path
    find('.js-new-url-url').set ':'
    find('.js-new-url-keyword').set keyword
    find('.js-url-submit').click

    expect do
      find('.js-url-submit').click
      wait_for_ajax
    end.to change(Url, :count).by(0)
  end

  it 'shows an error message if URL is not valid' do
    visit urls_path
    find('.js-new-url-url').set ':'
    find('.js-new-url-keyword').set keyword
    find('.js-url-submit').click

    expect(page).to have_content 'Url is not valid.'
  end

  it 'treats keyword as optional, creating a new zlink without it' do
    visit urls_path
    find('.js-new-url-url').set url
    find('.js-new-url-keyword').set ''

    expect do
      find('.js-url-submit').click
      # expect(page).to have_content(url)
    end.to change(Url, :count).by(1)
  end

  it 'does not create link if keyword is already taken' do
    # create another url with the same keyword
    @other_url = FactoryBot.create(:url)

    # now try creating a new zlink using the same keyword
    visit urls_path
    find('.js-new-url-url').set url
    find('#url_keyword').set @other_url.keyword

    # No new URL should be created
    expect do
      find('.js-url-submit').click
      wait_for_ajax
    end.to change(Url, :count).by(0)

    # Error Message should be displayed
    expect(page).to have_content('taken')
  end
end
