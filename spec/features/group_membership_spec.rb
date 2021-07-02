require 'rails_helper'


describe 'groups members index page' do
  before do
    @user = FactoryBot.create(:user, uid: 'wozniak')
  end

  describe 'visiting the group membership page' do
    let(:group) { FactoryBot.create(:group) }
    let(:user) { User.where(:uid => @user.uid).first }
    before do
      group.users << @user
      group.save
      sign_in(@user)
      visit group_members_path(group)
    end
    describe 'page content' do
      it 'should display the group name' do
        expect(page).to have_content group.name
      end
      it 'should display the group member full name' do
        expect(page).to have_content user.display_name
      end
      it 'should display the group member email' do
        expect(page).to have_content user.email
      end
      it 'should display a delete button' do
        expect(page).to have_content 'Remove'
      end
    end
  end

  describe 'creating and deleting a group member', js: true do
    describe 'to an existing group' do
      let(:group) { FactoryBot.create(:group) }
      before do
        group.users << @user
        group.save
        sign_in(@user)
        visit group_members_path(group)
      end
      it 'adding should increase the user count of the group by 1' do
        expect do
          js_make_all_inputs_visible
          find("#uid", visible: false).set '5scyi59j8'
          click_button 'Add'
          click_button 'Confirm'
          wait_for_ajax
          group.reload
        end.to change(group.users, :count).by(1)

      end
      it 'clicking delete decrease the user count by one' do
        expect do
          find('.delete-group-member').click
          click_button 'Confirm'
          wait_for_ajax
        end.to change(group.users, :count).by(-1)
      end

    end
  end
end
