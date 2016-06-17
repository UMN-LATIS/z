require 'rails_helper'

describe 'groups index page' do
  before do
    @user = FactoryGirl.create(:user)
    sign_in(@user)
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

  describe 'with an existing group' do
    let(:new_name) { 'My Second Group' }
    let(:new_description) { 'second group of urls' }
    before do
      visit groups_path
    end

    describe 'page content' do
      it 'should display the created user\'s group\'s uid as name (see User.before_validation)' do
        expect(page).to have_content @user.uid
      end
      it 'should display the group\'s description uid as description (see User.before_validation)' do
        expect(page).to have_content @user.uid
      end
      it 'should display an edit button' do
        expect(page).to have_content 'Edit'
      end
      it 'should display a delete button' do
        expect(page).to have_content 'Delete'
      end
    end

    describe 'when updating an existing group', js: true do
      before do
        find('.edit-group').click
      end

      describe 'with new valid content' do
        it 'should update the group name in the db' do
          find('#group_name').set new_name
          find('.js-group-submit').click
          wait_for_ajax
          find('.edit-group').click
          expect(find('#group_name')['value']).to eq(new_name)
        end
        it 'should update the group description in the db' do
          find('#group_description').set new_description
          find('.js-group-submit').click
          wait_for_ajax
          find('.edit-group').click
          expect(find('#group_description')['value']).to eq(new_description)
        end
      end
    end

    describe 'deleting an existing group', js: true do
      describe 'clicking delete' do
        it 'should delete the group' do
          expect do
            find('.delete-group').click
            wait_for_ajax
          end.to change(Group, :count).by(-1)
        end
      end
    end
  end


end