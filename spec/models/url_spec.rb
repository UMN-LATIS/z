# == Schema Information
#
# Table name: urls
#
#  id           :integer          not null, primary key
#  url          :string(255)
#  keyword      :string(255)
#  total_clicks :integer
#  group_id     :integer
#  modified_by  :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

require 'rails_helper'

RSpec.describe Url, type: :model do
  before do
    @user = FactoryGirl.create(:user)
    @url = FactoryGirl.build(:url)
  end

  subject { @url }

  it { should be_valid }
  it { should respond_to 'total_clicks' }
  it { should respond_to 'group' }
  it { should respond_to 'group_id' }
  it { should respond_to 'keyword' }
  it { should respond_to 'url' }
  it { should respond_to 'modified_by' }
  it { should respond_to 'created_at' }
  it { should respond_to 'updated_at' }

  describe 'invalid Url' do
    describe '[url]' do
      describe 'missing http' do
        before { @url.url = 'google.com' }
        it 'should not be valid' do
          expect(@url).to_not be_valid
        end
      end
      describe 'wrong caps' do
        before { @url.url = 'Http://fun.net' }
        it 'should not be valid' do
          expect(@url).to_not be_valid
        end
      end
      describe "doesn't exist" do
        before { @url.url = '' }
        it 'should not be valid' do
          expect(@url).to_not be_valid
        end
      end
    end
    describe '[keyword]' do
      describe 'already exists' do
        before do
          other_url = FactoryGirl.create(:url)
          @url.url = other_url.keyword
        end
        it 'should not be valid' do
          expect(@url).to_not be_valid
        end
      end
    end
  end

  describe 'valid url' do
    describe 'various urls' do
      it 'should be valid' do
        @url.url = 'http://fun.com'
        expect(@url).to be_valid
      end

      it 'should be valid' do
        @url.url = 'https://fun.com'
        expect(@url).to be_valid
      end

      it 'should be valid' do
        @url.url = 'http://fun.com'
        expect(@url).to be_valid
      end

      it 'should be valid' do
        @url.url = 'https://fun.com'
        expect(@url).to be_valid
      end
    end
  end
end
