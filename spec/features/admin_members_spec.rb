require 'rails_helper'


describe 'admin members index page' do
  before do
    @user = FactoryGirl.create(:user, admin: true, uid: 'wozniak')
    sign_in(@user)
    visit admin_members_path(@user)
  end

  describe 'visiting the group membership page' do
    let(:user) { User.where(:uid => 'wozniak').first }
    describe 'page content' do
      it 'should display the admin member uid' do
        expect(page).to have_content user.uid
      end
      it 'should display the admin member full name' do
        expect(page).to have_content user.user_full_name
      end
      it 'should display the admin member email' do
        expect(page).to have_content user.email
      end
    end
  end

  describe 'creating and deleting a admin member', js: true do
    describe 'to an existing group of admins' do
      let(:group) { FactoryGirl.create(:group) }
      it 'add and then set the new member admin flag to true' do
        find("#uid", :visible => false).set 'andersen'
        click_button 'Add'
        wait_for_ajax
        visit admin_members_path(@user)
        expect(User.where(uid: 'andersen', admin: true)).to exist
      end
      describe 'clicking delete' do
        it 'should first add a new member and then delete it' do
          find("#uid", :visible => false).set 'andersen'
          click_button 'Add'
          wait_for_ajax
          visit admin_members_path(@user)
          find('.delete-admin-member').click
          wait_for_ajax
          visit admin_members_path(@user)
          expect(User.where(uid: 'andersen', admin: true)).not_to exist
        end
      end

    end
  end
end
