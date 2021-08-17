require "pundit/rspec"
require 'rails_helper'

describe AuditPolicy do
  subject { described_class }

  before do
    @admin_user = FactoryBot.create(:user, admin: true, uid: 'wozniak')
    @bad_user = FactoryBot.create(:user, admin: false, uid: 'andersen')
  end

  permissions :index? do
    it 'allows access if user is an admin' do
      expect(subject).to permit(@admin_user)
    end

    it 'denies access if user is not admin' do
      expect(subject).not_to permit(@bad_user)
    end
  end
end
