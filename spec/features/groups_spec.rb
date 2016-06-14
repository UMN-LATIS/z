require 'rails_helper'

describe 'groups index page' do
  before do
    @user = FactoryGirl.create(:user)
    sign_in(@user)
  end

  describe 'with an existing group' do
    let(:new_name) { 'My First Group' }
    let(:new_description) { 'first group of urls' }
    before do
      @group = FactoryGirl.create(:group)
      visit groups_path
    end

    describe 'when editing existing group', js: true do
      before { find('.edit-group').click }

      describe 'with new valid content' do
        it 'should update the group in the db' do
          find('#group_name').set new_name
          find('.js-group-submit').click
          wait_for_ajax
          expect(@group.reload.name).to eq(new_name)
        end
        it 'should update the description in the db' do
          find('#group_description').set new_description
          find('.js-group-submit').click
          wait_for_ajax
          expect(@group.reload.description).to eq(new_description)
        end
      end
    end

    describe 'page content' do
      it 'should display the group\'s name' do
        expect(page).to have_content @group.name
      end
      it 'should display the group\'s description' do
        expect(page).to have_content @group.keyword
      end
      it 'should display the group\'s created at date' do
        expect(page).to have_content @group.created_at
      end
      it 'should display an edit button' do
        expect(page).to have_content 'Edit'
      end
      it 'should display a delete button' do
        expect(page).to have_content 'Delete'
      end
    end

    describe 'deleting an existing group' do
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



  describe 'creating a new group' do

    let(:name) { 'My First Group' }
    let(:description) { 'My first group of urls to keep things handy' }
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
            expect(page).to have_content('required')
          end
        end
      end
    end

  end

end