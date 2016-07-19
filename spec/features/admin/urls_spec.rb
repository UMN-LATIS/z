require 'rails_helper'

describe 'as a valid admin user' do
  before do
    @admin = FactoryGirl.create(:admin)
    sign_in(@admin)
  end

  describe 'visiting admin url index' do
    before { visit admin_urls_path }
    it 'display the URL title' do
      expect(page).to have_content "Urls"  
    end
  end
end
