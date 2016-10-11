require "pundit/rspec"
require 'rails_helper'


describe TransferRequestPolicy do
  subject { described_class }

  before do
    @admin_user = FactoryGirl.create(:user, admin: true, uid: 'wozniak')
    @bad_user = FactoryGirl.create(:user, admin: false, uid: 'andersen')
    @transfer_request = FactoryGirl.create(:transfer_request)
  end

  permissions :destroy?, :update?, :show?, :confirm?  do
    it 'allows access if user is an admin' do
      expect(subject).to permit(@admin_user, @transfer_request)
    end
    it 'denies access if user is not in group and not admin' do
      expect(subject).not_to permit(@bad_user, @transfer_request)
    end
  end
end