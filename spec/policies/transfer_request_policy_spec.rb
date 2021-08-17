require "pundit/rspec"
require 'rails_helper'

describe TransferRequestPolicy do
  subject { described_class }

  before do
    @admin_user = FactoryBot.create(:user, admin: true)
    @bad_user = FactoryBot.create(:user, admin: false)
    @good_user = FactoryBot.create(:user)
    @group = FactoryBot.create(:group)
    @group.add_user(@good_user, false)
    @transfer_request = FactoryBot.create(:transfer_request)
    @transfer_request.update(from_group: @group)
  end

  permissions :destroy?, :update?, :show?, :confirm? do
    it 'allows access if user is an admin' do
      expect(subject).to permit(@admin_user, @transfer_request)
    end
    it 'allows access if user is in the from group of the transfer' do
      expect(subject).to permit(@good_user, @transfer_request)
    end
    it 'denies access if user is not in group and not admin' do
      expect(subject).not_to permit(@bad_user, @transfer_request)
    end
  end
end
