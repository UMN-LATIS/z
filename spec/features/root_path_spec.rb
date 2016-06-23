require 'rails_helper'

describe 'Visiting root' do
  let(:user) { FactoryGirl.create(:user) }
  describe 'not signed in' do
    before { visit '/' }

    it 'should say hello' do
      expect(page).to have_content 'hello'
    end
  end

  describe 'signed in' do
    before do
      sign_in user
      visit '/'
    end

    it 'should direct you to the home page' do
      expect(page).to have_content 'hello'
    end
  end
end
