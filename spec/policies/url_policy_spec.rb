require "pundit/rspec"
require 'rails_helper'


describe UrlPolicy do
  subject { described_class }

  before do
    @good_user = FactoryBot.create(:user)
    @bad_user = FactoryBot.create(:user)
    @admin_user = FactoryBot.create(:user, admin: true, uid: 'wozniak')
    @url = FactoryBot.create(
        :url,
        group: @good_user.context_group,
        keyword: 'keyword',
        url: 'http://google.com',
        created_at: 'created_at'
    )
  end

  permissions :update?, :edit?, :show?, :transfer_requests?, :csvs?, :index? do
    it 'allows access if user is part of the Urls group' do
      expect(subject).to permit(@good_user, @url)
    end
    it 'allows access if user is an admin' do
      expect(subject).to permit(@admin_user, @url)
    end
    it 'denies access if user is not part of the urls group' do
      expect(subject).not_to permit(@bad_user, @url)
    end
  end

  permissions :admin_transfer_requests? do
    it 'allows access if user is an admin' do
      expect(subject).to permit(@admin_user, @url)
    end
    it 'denies access if user is not an admin' do
      expect(subject).not_to permit(@bad_user, @url)
    end
  end

end
