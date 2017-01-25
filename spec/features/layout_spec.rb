require 'rails_helper'

describe 'the layout' do
  let(:user) { FactoryGirl.create(:user) }
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
      expect(page).to have_link 'URLs'
    end
    it 'should have a Collections link' do
      expect(page).to have_link 'Collections'
    end
  end
end
