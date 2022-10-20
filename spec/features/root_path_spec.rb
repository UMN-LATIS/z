require 'rails_helper'

describe 'Visiting root' do
  let(:user) { FactoryBot.create(:user) }

  describe 'not signed in' do
    before { visit '/' }

    it 'says Welcome' do
      expect(page).to have_content 'Welcome'
    end

    it 'displays Login to Z button' do
      expect(page).to have_content 'Sign In to Z'
    end
  end

  describe 'signed in' do
    before do
      sign_in user
      visit '/'
    end

    it 'directs you to the home page' do
      expect(page).to have_content 'z.umn.edu'
    end

    it 'not display Login to Z button' do
      expect(page).not_to have_content 'Login to Z'
    end
  end
end
