require 'rails_helper'

describe 'the layout' do
  let(:user) { FactoryBot.create(:user) }

  describe 'not signed in' do
    before { visit '/' }

    it 'has a sign in link' do
      expect(page).to have_link 'Sign In'
    end

    it 'does not have a sign out link' do
      expect(page).not_to have_link 'Sign Out'
    end

    it 'does not have a URLs link' do
      expect(page).not_to have_link 'URLs'
    end

    it 'does not have a Groups link' do
      expect(page).not_to have_link 'Groups'
    end
  end

  describe 'signed in' do
    before do
      sign_in user
      visit '/'
    end

    it 'has a sign out link' do
      expect(page).to have_link 'Sign Out'
    end

    it 'has a URLs link' do
      expect(page).to have_link 'My Z-Links'
    end

    it 'has a Collections link' do
      expect(page).to have_link 'Collections'
    end

    it 'has a Whats new link' do
      click_link 'Help'
      expect(page).to have_link "What's New in Z"
    end
  end
end
