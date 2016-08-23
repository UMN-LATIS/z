require 'rails_helper'


describe 'groups members index page' do
  before do
    @user = FactoryGirl.create(:user, uid:'wozniak')
    sign_in(@user)
    group.users << @user
    group.save
    visit group_members_path(group)
  end

  describe 'visiting the group membership page' do
    let(:group) { FactoryGirl.create(:group) }
    let(:user) {User.where(:uid => @user.uid).first}
    describe 'page content' do
      it 'should display the group name' do
        expect(page).to have_content group.name
      end
      it 'should display the group member uid' do
        expect(page).to have_content @user.uid
      end
      it 'should display the group member full name' do
        expect(page).to have_content user.user_full_name
      end
      it 'should display the group member email' do
        expect(page).to have_content user.email
      end
      it 'should display a delete button' do
        expect(page).to have_content 'Delete'
      end
    end
  end

  describe 'creating and deleting a group member', js: true do
    describe 'to an existing group' do
      let(:group) { FactoryGirl.create(:group) }
      it 'adding should increase the user count of the group by 1' do
        expect do
          find("#uid", :visible => false).set 'andersen'
          click_button 'Add'
          wait_for_ajax
          group.reload
        end.to change(group.users, :count).by(1)

      end
      describe 'clicking delete' do
        it 'should delete the group member' do
          expect do
            find('.delete-group-member').click
            wait_for_ajax
          end.to change(group.users, :count).by(-1)
        end
      end

    end
  end
end
