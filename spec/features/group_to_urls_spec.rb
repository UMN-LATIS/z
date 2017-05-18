require 'rails_helper'

describe 'with a group that has URLs', js: true do
  let(:group) { FactoryGirl.create(:group) }
  let(:other_group) { FactoryGirl.create(:group) }
  let(:user) { FactoryGirl.create(:user) }
  let(:url) { FactoryGirl.create(:url) }
  before do
    user.groups << group
    user.groups << other_group
    group.urls << url
    group.save
    sign_in user
    visit groups_path
  end

  describe 'clicking the group name' do
    describe 'when the group has URLs' do
      before do
        click_link(group.name)
      end

      it 'should pre-select the collection' do
        expect(page).to have_select('collection-filter', visible: false, selected: group.name)
      end
      it 'should display the URL in the collection' do
        expect(page).to have_content(url.keyword)
      end
    end
    describe 'when the group does not have URLs' do
      before do
        click_link(other_group.name)
      end

      it 'should pre-select the collection' do
        expect(page).to have_select('collection-filter', visible: false, selected: other_group.name)
      end
      it 'should not display the URL' do
        expect(page).to_not have_content(url.keyword)
      end
    end
  end
end
