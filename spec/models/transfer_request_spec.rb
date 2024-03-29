require 'rails_helper'

RSpec.describe TransferRequest, type: :model do
  subject { @transfer_request }

  before do
    @transfer_request = FactoryBot.build(:transfer_request)
  end

  it { is_expected.to be_valid }
  it { is_expected.to respond_to 'to_group' }
  it { is_expected.to respond_to 'to_group_id' }
  it { is_expected.to respond_to 'from_group' }
  it { is_expected.to respond_to 'from_group_id' }

  it { is_expected.to respond_to 'created_at' }
  it { is_expected.to respond_to 'updated_at' }

  describe 'Versioning' do
    it 'is enabled' do
      expect(subject).to be_versioned
    end
  end

  describe 'for admin in the from group of the request' do
    before do
      @admin_user = FactoryBot.create(:admin)
      @transfer_url = FactoryBot.create(:url)
      @transfer_url.group_id = @admin_user.context_group_id
      @transfer_request.urls << @transfer_url
      @transfer_request.save
    end

    it 'status should be pending' do
      expect(@transfer_request.status.eql?('pending')).to be true
    end
  end

  describe 'for an admin not in either of the groups of a url' do
    before do
      @user1 = FactoryBot.create(:user)
      @user2 = FactoryBot.create(:user)
      @admin_user = FactoryBot.create(:admin)

      @transfer_request.from_group_id =
        @user1.context_group_id
      @transfer_request.to_group_id =
        @user2.context_group_id

      @transfer_request.from_user =
        @admin_user
      @transfer_request.to_user =
        @user2
      @transfer_request.save
    end

    it 'status should be approved' do
      expect(@transfer_request.status.eql?('approved')).to be true
    end
  end

  describe 'invalid TransferRequest' do
    describe '[to_group]' do
      describe "doesn't exist" do
        before { @transfer_request.to_group = nil }

        it 'is not valid' do
          expect(@transfer_request).not_to be_valid
        end
      end
    end

    describe '[from_group]' do
      describe "doesn't exist" do
        before { @transfer_request.from_group = nil }

        it 'is not valid' do
          expect(@transfer_request).not_to be_valid
        end
      end

      describe "doesn't own urls" do
        describe 'and is not admin' do
          before { @transfer_request.urls = [FactoryBot.create(:url)] }

          it 'is not valid' do
            expect(@transfer_request).not_to be_valid
          end
        end

        describe 'and is an admin' do
          before do
            @transfer_request.from_group_id =
              FactoryBot.create(:admin).context_group_id
          end

          it 'is valid' do
            expect(@transfer_request).to be_valid
          end
        end
      end
    end
  end
end
