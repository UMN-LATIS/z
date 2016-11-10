# spec/services/user_lookup_service_test.rb

require 'rails_helper'

RSpec.describe UserLookupService, type: :service do
  describe 'it can lookup by last name' do
    let(:last_name) { "Andersen" }
    let(:fake_last_name) { "as;ldfjoqujfas;lkdfjalsk;dfj" }

    it 'should find users' do
      users = UserLookupService.new(
        query: last_name,
        query_type: 'last_name'
      ).search
      expect(users).to be_present
    end

    it 'should not find fake users' do
      users = UserLookupService.new(
        query: fake_last_name,
        query_type: 'last_name'
      ).search

      expect(users).to be_empty
    end
  end

  describe 'it can lookup by email' do
    let(:email) { 'andersen@umn.edu' }
    let(:fake_email) { 'alsdfjal;iasdl;ifjasdl;ifjadsli;fjndersen@umn.edu' }
    
    it 'should find one user' do
      users = UserLookupService.new(
        query: email,
        query_type: 'mail'
      ).search
      expect(users.length).to eq(1)
    end
    it 'should not find a fake user' do
      users = UserLookupService.new(
        query: fake_email,
        query_type: 'mail'
      ).search
      expect(users).to be_empty
    end
  end
end
