# frozen-string-literal: true

require 'rails_helper'

describe 'collection assignment dropdown', js: true do
  let(:user) { FactoryBot.create(:user) }

  before do
    @url = FactoryBot.create(:url, group: user.context_group)
    @new_group = FactoryBot.create(:group)
    @new_group.users << user
    sign_in(user)
    wait_for_ajax
    visit urls_path
    wait_for_ajax
    find('table .bootstrap-select .dropdown-toggle').click
  end

  it 'changes a collection' do
    expect(page).to have_content("All")
    accept_confirm do
      find('.dropdown-menu.open').find('li', text: @new_group.name).click
    end
    expect(page).to have_selector('table .bootstrap-select .dropdown-toggle', text: @new_group.name)
  end

  it 'updates the urls collection in the database' do
    expect(page).to have_content("All")
    accept_confirm do
      find('.dropdown-menu.open').find('li', text: @new_group.name).click
    end
    @url.reload
    expect(@url.group.id).to eq(@new_group.id)
  end

  it 'creates a new collection' do
    expect(page).to have_content("All")
    find('table .dropdown-menu.open .bottom-action-option').click
    # modal should display
    expect(page).to have_selector('#index-modal')

    # fill in the form
    another_group_name = "another group"
    another_group_description = "another group description"
    find('.modal input#group_name').set another_group_name
    find('.modal input#group_description').set another_group_description
    find('.modal input[type="submit"]').click
    click_button "Confirm"

    # colection picker is updated
    expect(page).to have_selector('table .bootstrap-select .dropdown-toggle', text: another_group_name)

    # url in database is updated
    @url.reload
    expect(@url.group.name).to eq(another_group_name)
  end
end
