# frozen-string-literal: true

require 'rails_helper'

describe 'z index page: when editing existing url', js: true do
  let(:user) { FactoryBot.create(:user) }
  let(:new_url) { 'http://www.facebook.com' }
  let(:new_keyword) { 'face' }

  before do
    @url = FactoryBot.create(:url, group: user.context_group)
    sign_in(user)
    visit urls_path
  end

  it 'updates the url in the db' do
    find('.dropdown .actions-dropdown-button').click
    find('.dropdown-menu .edit-url').click

    find('table #url_url').set new_url
    find('table .js-url-submit').click
    expect(@url.reload.url).to eq(new_url)
  end

  it 'updates the keyword in the db' do
    find('.dropdown .actions-dropdown-button').click
    find('.dropdown-menu .edit-url').click
    find('table #url_keyword').set new_keyword
    find('table .js-url-submit').click
    expect(@url.reload.keyword).to eq(new_keyword)
  end

  it 'deletes the url' do
    expect do
      find('.dropdown .actions-dropdown-button').click
      find('.dropdown-menu .delete-url').click
      click_button "Confirm"
    end.to change(Url, :count).by(-1)
  end

  context 'when user attempts to edit someone elses url' do
    let(:another_user) { FactoryBot.create(:user) }

    before do
      @another_users_url = FactoryBot.create(:url, group: another_user.context_group)
    end

    it 'displays not authorized message' do
      visit edit_url_path(@another_users_url)
      expect(page).to have_content 'You are not authorized to perform this action.'
    end
  end
end
