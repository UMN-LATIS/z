require 'rails_helper'


describe 'groups members index page' do
  before do
    @user = FactoryGirl.create(:user)
    sign_in(@user)
  end


  describe 'creating and deleting a group member', js: true do
    describe 'to an existing group' do
      let(:group) { FactoryGirl.create(:group) }
      before do
        group.users << @user
        group.save
        sign_in @user
        visit group_members_path(group)
      end

      it 'adding should increase the user count of the group by 1' do
        fill_in 'people_search', :with => 'andersen'
        expect do
          click_button 'Add'
          wait_for_ajax
        end.to change(group.users, :count).by(1)

      end

      it 'deleting should decrease the number of group users by one' do
        expect do
          visit group_member_path(group, @user)
          puts page.body
          delete :destroy, {:group_id => group.id, :id => @user.id}
        end.to change(group.users, :count).by(-1)

      end
    end
  end


end
