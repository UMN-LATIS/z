require 'rails_helper'

describe 'as a non-admin user visiting the admin page' do
  before do
    @user = FactoryBot.create(:user)
    @announcement = FactoryBot.create(:announcement)
    sign_in(@user)
    visit admin_announcements_path
  end
  it 'should display an access violation' do
    expect(page).to have_content 'You are not authorized to perform this action.'
  end
end

describe 'as a valid user' do
  before do
    @user = FactoryBot.create(:user)
    @announcement = FactoryBot.create(:announcement)
    sign_in(@user)
    visit urls_path
  end

  it 'should display the announcement ' do
    expect(page).to have_content 'The Court is in Session'
  end
end

describe 'as a valid admin user' do
  before do
    @admin = FactoryBot.create(:admin)
    sign_in(@admin)
    visit admin_announcements_path
  end

  it 'should display announcement body' do
    expect(page).to have_content 'Message'
  end

  it 'should display announcement start by date' do
    expect(page).to have_content 'Start delivering at'
  end

  it 'should display announcement end by date' do
    expect(page).to have_content 'Stop delivering at'
  end
  describe 'without an announcement' do
    it 'should display invitation to add an announcement' do
      expect(page).to have_content 'No Announcements. Click'
    end
  end

  describe 'with an announcement' do
    before do
      @announcement = FactoryBot.create(:announcement)
      visit admin_announcements_path
    end
    it 'should not display invitation to add an announcement' do
      expect(page).to_not have_content 'No Announcements. Click'
    end
  end
end
