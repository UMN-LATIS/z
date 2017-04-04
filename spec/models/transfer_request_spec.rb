require 'rails_helper'

RSpec.describe TransferRequest, type: :model do
  before do
    @transfer_request = FactoryGirl.build(:transfer_request)
  end

  subject { @transfer_request }

  it { should be_valid }
  it { should respond_to 'to_group' }
  it { should respond_to 'to_group_id' }
  it { should respond_to 'from_group' }
  it { should respond_to 'from_group_id' }

  it { should respond_to 'created_at' }
  it { should respond_to 'updated_at' }

  describe 'Versioning' do
    it 'should be enabled' do
      is_expected.to be_versioned
    end
  end

  describe 'for admin in the from group of the request' do
      before do
        @admin_user = FactoryGirl.create(:admin)
        @transfer_url = FactoryGirl.create(:url)
        @transfer_url.group_id = @admin_user.context_group_id
        @transfer_request.urls << @transfer_url
        @transfer_request.save
      end
      it 'status should be pending' do
        expect(@transfer_request.status.eql? 'pending').to be true
      end
  end

  describe 'for an admin not in either of the groups of a url' do
    before do
      @user1 = FactoryGirl.create(:user)
      @user2 = FactoryGirl.create(:user)
      @admin_user = FactoryGirl.create(:admin)

      @transfer_request.from_group_id =
          @user1.context_group_id
      @transfer_request.to_group_id =
          @user2.context_group_id

      @transfer_request.from_user =
          @admin_user
      @transfer_request.to_user=
          @user2
      @transfer_request.save
    end
    it 'status should be approved' do
      expect(@transfer_request.status.eql? 'approved').to be true
    end
  end


  describe 'invalid TransferRequest' do
    describe '[to_group]' do
      describe "doesn't exist" do
        before { @transfer_request.to_group = nil }

        it 'should not be valid' do
          expect(@transfer_request).to_not be_valid
        end
      end
    end
    describe '[from_group]' do
      describe "doesn't exist" do
        before { @transfer_request.from_group = nil }

        it 'should not be valid' do
          expect(@transfer_request).to_not be_valid
        end
      end
      describe "doesn't own urls" do
        describe 'and is not admin' do
          before { @transfer_request.urls = [FactoryGirl.create(:url)] }

          it 'should not be valid' do
            expect(@transfer_request).to_not be_valid
          end
        end
        describe 'and is an admin' do
          before do
            @transfer_request.from_group_id =
                FactoryGirl.create(:admin).context_group_id
          end

          it 'should be valid' do
            expect(@transfer_request).to be_valid
          end
        end
      end
    end
  end
end
