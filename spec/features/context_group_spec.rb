require 'rails_helper'

describe 'context switching' do
  let(:user) { FactoryGirl.create(:user) }
  describe 'not signed in' do
    before { visit '/' }

    it 'should not have a Viewing As Section' do
      expect(page).to_not have_content 'Viewing As:'
    end
  end

  describe 'signed in' do
    before do
      sign_in user
      visit '/'
    end

    it 'should have a Viewing As section' do
      expect(page).to have_content 'Viewing As:'
    end
    describe 'when user has multiple groups' do
      let(:group) { FactoryGirl.create(:group) }
      before do
        user.groups << group
        visit '/'
      end
      it 'should have a Viewing As section' do
        expect(page).to have_content "Viewing As: #{user.context_group.name}"
      end
      describe 'when switching contexts', js: true do
        before do
          click_link "Viewing As: #{user.context_group.name}"
          click_link group.name
        end
        it 'should switch the context' do
          expect(page).to have_content "Viewing As: #{group.name}"
        end
      end
    end
  end
end
