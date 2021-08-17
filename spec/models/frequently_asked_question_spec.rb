require 'rails_helper'

RSpec.describe FrequentlyAskedQuestion, type: :model do
  subject { @frequently_asked_question }

  before do
    @frequently_asked_question = FactoryBot.build(:frequently_asked_question)
  end

  it { is_expected.to be_valid }
  it { is_expected.to respond_to 'header' }
  it { is_expected.to respond_to 'question' }
  it { is_expected.to respond_to 'answer' }
  it { is_expected.to respond_to 'created_at' }
  it { is_expected.to respond_to 'updated_at' }
end
