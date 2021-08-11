require 'rails_helper'

describe 'groups index page', js: true do
  before do
    @user = FactoryBot.create(:user)
    sign_in(@user)
    wait_for_ajax
  end

  describe 'creating a new group', js: true do
    let(:name) { 'My First Group' }
    let(:description) { 'first group of urls' }
    before do
      visit groups_path
      find('.add-new-group').click
      wait_for_ajax
      find('#group_name').set name
      find('#group_description').set description
    end
    describe 'with valid information' do
      describe 'when both fields are filled in' do
        it 'should save upon clicking Create' do
          expect do
            find('.js-group-submit').click
            wait_for_ajax
          end.to change(Group, :count).by(1)
        end
        it 'should add the user to the group' do
          expect do
            find('.js-group-submit').click
            wait_for_ajax
          end.to change(GroupsUser, :count).by(1)
        end
      end
      describe 'when the description is blank' do
        before { find('#group_description').set '' }
        it 'should save upon clicking Create' do
          expect do
            find('.js-group-submit').click
            wait_for_ajax
          end.to change(Group, :count).by(1)
        end
      end
    end
    describe 'with invalid information' do
      describe '[name]' do
        describe 'name is blank' do
          before { find('#group_name').set '' }
          it 'should not save upon clicking Create' do
            expect do
              find('.js-group-submit').click
              wait_for_ajax
            end.to change(Group, :count).by(0)
          end
          it 'should display an error' do
            find('.js-group-submit').click
            wait_for_ajax
            expect(page).to have_content('Name can\'t be blank')
          end
        end
      end
    end
  end

  describe 'with an existing group', js: true do
    let(:new_name) { 'My Second Group' }
    let(:new_description) { 'second group of urls' }
    let(:group) { FactoryBot.create(:group) }
    before do
      group.users << @user
      group.save
      sign_in @user
      wait_for_ajax
      visit groups_path
      wait_for_ajax
    end

    describe 'page content' do
      it 'should display the group name' do
        expect(page).to have_content group.name
      end
      it 'should display the group description' do
        expect(page).to have_content group.description
      end
      it 'should display an edit button' do
        find('.js-group-actions-dropdown').click
        expect(page).to have_content 'Edit'
      end
      it 'should display a delete button' do
        find('.js-group-actions-dropdown').click
        expect(page).to have_content 'Delete'
      end
    end

    describe 'when updating an existing group', js: true do
      before do
        find('.js-group-actions-dropdown').click
        find('.edit-group').click
      end

      describe 'with new valid content' do
        it 'should update the group name in the db' do
          find('#group_name').set new_name
          find('.js-group-submit').click
          wait_for_ajax
          find('.js-group-actions-dropdown').click
          find('.edit-group').click
          expect(find('#group_name')['value']).to eq(new_name)
        end
        it 'should update the group description in the db' do
          find('#group_description').set new_description
          find('.js-group-submit').click
          wait_for_ajax
          find('.js-group-actions-dropdown').click
          find('.edit-group').click
          expect(find('#group_description')['value']).to eq(new_description)
        end
      end
    end

    describe 'deleting an existing group', js: true do
      describe 'clicking delete' do
        describe 'on a group with urls' do
          before { group.urls << FactoryBot.create(:url) }
          it 'should not delete the group' do
            expect do
              find('.js-group-actions-dropdown').click
              find('.delete-group').click
              click_button "Confirm"
              wait_for_ajax
            end.to change(Group, :count).by(0)
          end
        end
        describe 'on a group without urls' do
          it 'should delete the group' do
            expect do
              find('.js-group-actions-dropdown').click
              find('.delete-group').click
              click_button "Confirm"
              wait_for_ajax
            end.to change(Group, :count).by(-1)
          end
        end
      end
    end
  end

  describe 'when attempting to edit someone elses group' do
    before do
      unauthed_group = FactoryBot.create(:group)
      visit edit_group_path(unauthed_group)
    end
    describe 'page content' do
      it 'should display the not authorized message' do
        expect(page).to have_content 'You are not authorized to perform this action.'
      end
    end
  end


end
