require "pundit/rspec"
require 'rails_helper'


describe GroupPolicy do
  subject { described_class }

  before do
    @group = FactoryGirl.create(:group)
    @good_user = FactoryGirl.create(:user)
    @group.add_user(@good_user, false)
    @bad_user = FactoryGirl.create(:user)
    @admin_user = FactoryGirl.create(:user, admin: true, uid: 'wozniak')
  end

  permissions :update?, :destroy?, :show?, :index? do
    it 'allows access if user is an admin' do
      expect(subject).to permit(@admin_user, @group)
    end
    it 'denies access if user is not part of the group' do
      expect(subject).not_to permit(@bad_user, @group)
    end
    it 'allows access if user is part of the group' do
      expect(subject).to permit(@good_user, @group)
    end
  end

end


