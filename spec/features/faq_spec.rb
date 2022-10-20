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

    it 'gives you the title of the page' do
      expect(page).to have_content 'Z Frequently Asked Questions'
    end

    it 'has a header for a group of faqs' do
      expect(page).to have_content 'Header'
    end

    it 'has a question' do
      expect(page).to have_content 'Question'
    end

    it 'does not have an answer displayed before the question is clicked on' do
      expect(page).not_to have_content 'Answer'
    end

    it 'has an answer when a question is clicked on' do
      click_link('Question')
      expect(page).to have_content 'Answer'
    end
  end
end
