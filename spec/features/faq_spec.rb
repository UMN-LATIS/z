require 'rails_helper'

describe 'visit the faq page ' do
  before do
    @user = FactoryBot.create(:user)
    sign_in(@user)
  end

  describe 'index page', js: true do
    before do
      FactoryBot.create(:frequently_asked_question)
      visit faq_path
    end
    it 'should give you the title of the page' do
      expect(page).to have_content 'Z Frequently Asked Questions'
    end
    it 'should have a header for a group of faqs' do
      expect(page).to have_content 'Header'
    end
    it 'should have a question' do
      expect(page).to have_content 'Question'
    end
    it 'should not have an answer displayed before the question is clicked on' do
      expect(page).to_not have_content 'Answer'
    end
    it 'should have an answer when a question is clicked on' do
      click_link('Question')
      expect(page).to have_content 'Answer'
    end

  end
end
