# frozen-string-literal: true

require 'rails_helper'

describe 'urls index page: list existing urls', js: true do
  let(:user) { FactoryBot.create(:user) }
  let(:url) { FactoryBot.create(:url) }

  before do
    # set this url to be owned by the user
    url.update(group: user.context_group)

    sign_in(user)
    visit urls_path
  end

  it 'displays the long url' do
    expect(page).to have_content url.url
  end

  it 'displays short url host' do
    expect(page).to have_content page.current_host.sub(%r{^https?://(www.)?}, '')
  end

  it 'displays the url\'s keyword' do
    expect(page).to have_content url.keyword
  end

  it 'displays the url\'s click count' do
    expect(page).to have_css('td', text: url.total_clicks)
  end

  it 'displays the action dropdown button' do
    expect(page).to have_selector('.actions-column .actions-dropdown-button')
  end

  it 'displays the default urls display_name' do
    expect(page).to have_selector(
      "[data-id='url-collection-#{url.id}']",
      text: I18n.t('views.urls.index.table.collection_filter.none')
    )
  end

  it 'filters on collection', js: true do
    # create a new collection
    new_group = FactoryBot.create(:group)

    # add current user to it
    new_group.users << user

    # add a new url to the collection
    new_url = FactoryBot.create(:url, group: new_group)

    # reload page
    visit urls_path

    # open the collections dropdown
    find('[data-id="collection-filter"]').click

    # choose the new collection from the list
    expect(page).to have_content(new_group.name)
    find('.dropdown-menu.open li', text: new_group.name).click

    # it shows urls from this collection, but not other collections
    expect(page).to have_content new_url.keyword
    expect(page).not_to have_content url.keyword
  end

  it 'filters on url keyword' do
    create_url_for_user(user, { url: 'https://tc.umn.edu', keyword: 'twin-cities' })
    create_url_for_user(user, { url: 'https://mrs.umn.edu', keyword: 'morris' })

    # type part of the keyword into the searchbox
    within '#urls-table_wrapper' do
      # based on current factory, last letter of a keyword should be a number
      # unique to the zlink
      fill_in 'Search', with: 'twin'
      expect(page).to have_content('twin-cities')
      expect(page).to have_no_content('morris')
    end
  end

  it 'filters on long url' do
    # create urls associated with the User
    create_url_for_user(user, { url: 'https://tc.umn.edu', keyword: 'twin-cities' })
    create_url_for_user(user, { url: 'https://mrs.umn.edu', keyword: 'morris' })

    within '#urls-table_wrapper' do
      fill_in 'Search', with: 'tc'
      expect(page).to have_content('twin-cities')
      expect(page).to have_no_content('morris')
    end
  end
end
