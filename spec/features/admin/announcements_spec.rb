require 'rails_helper'

describe 'as a non-admin user visiting the admin page' do
  before do
    @user = FactoryGirl.create(:user)
    @announcement = FactoryGirl.create(:announcement)
    sign_in(@user)
    visit admin_announcements_path
  end
  it 'should display an access violation' do
    expect(page).to have_content 'You are not authorized to perform this action.'
  end

end


describe 'as a valid user' do
  before do
    @user = FactoryGirl.create(:user)
    @announcement = FactoryGirl.create(:announcement)
    sign_in(@user)
    visit urls_path
  end

  it 'should display the announcement ' do
    expect(page).to have_content 'The Court is in Session'
  end

end



describe 'as a valid admin user' do
  before do
    @admin = FactoryGirl.create(:admin)
    sign_in(@admin)
    visit admin_announcements_path
  end

  it 'should display the announcement title' do
    expect(page).to have_content 'Title'
  end

  it 'should display announcement body' do
    expect(page).to have_content 'Body'
  end

  it 'should display announcement start by date' do
    expect(page).to have_content 'Start delivering at'
  end

  it 'should display announcement end by date' do
    expect(page).to have_content 'Stop delivering at'
  end

end
