# spec/services/user_lookup_service_test.rb

require 'rails_helper'

RSpec.describe UserLookupService, type: :service do
  describe 'it can lookup by umndid' do
    let(:umndid) { '2qggnq4v3' }
    let(:fakeumndid) { 'as;ldfjoqujfas;lkdfjalsk;dfj' }

    it 'should find users' do
      users = UserLookupService.new(
        query: umndid,
        query_type: 'umndid'
      ).search
      expect(users).to be_present
    end

    it 'should not find fake users' do
      users = UserLookupService.new(
        query: fakeumndid,
        query_type: 'umndid'
      ).search

      expect(users).to be_empty
    end
  end

  describe 'it can lookup by internet_id' do
    let(:internetid) { 'andersen' }
    let(:fake_internetid) { 'alsdfjal;iasdl;ifjasdl;ifjadsli;fjndersen@umn.edu' }

    it 'should find one user' do
      users = UserLookupService.new(
        query: internetid,
        query_type: 'all'
      ).search
      expect(users).to be_present
    end
    it 'should not find a fake user' do
      users = UserLookupService.new(
        query: fake_internetid,
        query_type: 'all'
      ).search
      expect(users).to be_empty
    end
  end
end
