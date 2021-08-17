# == Schema Information
#
# Table name: groups
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  description :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
require 'rails_helper'

RSpec.describe Group, type: :model do
  before do
    @group = FactoryBot.build(:group)
  end

  subject { @group }

  it { should be_valid }
  it { should respond_to 'name' }
  it { should respond_to 'description' }
  it { should respond_to 'created_at' }
  it { should respond_to 'updated_at' }

  describe 'Versioning' do
    it 's should be enabled' do
      is_expected.to be_versioned
    end
  end

  describe 'invalid Group' do
    describe '[name]' do
      describe 'doesn\'t exist' do
        before { @group.name = '' }
        it 'should not be valid' do
          expect(@group).to_not be_valid
        end
      end
    end
  end

  describe 'calling add_user' do
    before do
      @user = FactoryBot.create(:user)
      @group = FactoryBot.create(:group)
    end
    describe 'should add a user' do
      before { @group.add_user @user }
      it ' and include user in group.users' do
        expect(@group.users).to include(@user)
      end
    end
  end

  describe 'calling user?' do
    before do
      @user = FactoryBot.create(:user)
      @user_not = FactoryBot.create(:user)
      @group = FactoryBot.create(:group)
      @group.add_user @user
    end
    describe 'should have a user' do
      it ' and return true when asked if user?' do
        expect(@group.user? @user).to be true
      end
    end

    describe 'should not have a user' do
      it ' and return true when asked if user?' do
        expect(@group.user? @user_not).to be false
      end
    end
  end

  describe 'calling remove_user' do
    before do
      @user = FactoryBot.create(:user)
      @group = FactoryBot.create(:group)
      @group.add_user @user
    end
    describe 'should have and remove user:' do
      before { @group.remove_user @user }
      it 'and then remove it' do
        expect(@group.users).not_to include(@user)
      end
    end
  end

  describe 'calling default?' do
    before do
      @default_group = FactoryBot.create(:user).default_group
    end

    it 'should be false for non-default groups' do
      expect(@group.default?).to eq(false)
    end

    it 'should be true for default groups' do
      expect(@default_group.default?).to eq(true)
    end
  end
end
