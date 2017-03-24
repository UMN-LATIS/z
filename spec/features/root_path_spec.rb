require 'rails_helper'

describe 'Visiting root' do
  let(:user) { FactoryGirl.create(:user) }
  describe 'not signed in' do
    before { visit '/' }

    it 'should say Welcome' do
      expect(page).to have_content 'Welcome'
    end
    it 'should display Login to Z button' do
      expect(page).to have_content 'Login to Z'
    end
  end

  describe 'signed in' do
    before do
      sign_in user
      visit '/'
    end

    it 'should direct you to the home page' do
      expect(page).to have_content 'z.umn.edu'
    end
    it 'not display Login to Z button' do
      expect(page).to_not have_content 'Login to Z'
    end
  end
end
