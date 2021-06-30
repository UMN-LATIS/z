require 'rails_helper'

describe 'the layout' do
  let(:user) { FactoryBot.create(:user) }
  describe 'not signed in' do
    before { visit '/' }

    it 'should have a sign in link' do
      expect(page).to have_link 'Sign In'
    end
    it 'should not have a sign out link' do
      expect(page).to_not have_link 'Sign Out'
    end
    it 'should not have a URLs link' do
      expect(page).to_not have_link 'URLs'
    end
    it 'should not have a Groups link' do
      expect(page).to_not have_link 'Groups'
    end
  end

  describe 'signed in' do
    before do
      sign_in user
      visit '/'
    end

    it 'should have a sign out link' do
      expect(page).to have_link 'Sign Out'
    end
    it 'should have a URLs link' do
      expect(page).to have_link 'My Z-Links'
    end
    it 'should have a Collections link' do
      expect(page).to have_link 'Collections'
    end

    it 'should have a Whats new link' do
      click_link 'Help'
      expect(page).to have_link "What's New in Z"
    end
  end
end
