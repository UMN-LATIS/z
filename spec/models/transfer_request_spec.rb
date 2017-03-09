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

  describe 'Versioning'do
    it 's should be enabled' do
      is_expected.to be_versioned
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
