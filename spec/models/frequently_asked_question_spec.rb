require 'rails_helper'

RSpec.describe FrequentlyAskedQuestion, type: :model do
  before do
    @frequently_asked_question = FactoryGirl.build(:frequently_asked_question)
  end

  subject { @frequently_asked_question }

  it { should be_valid }
  it { should respond_to 'header' }
  it { should respond_to 'question' }
  it { should respond_to 'answer' }
  it { should respond_to 'created_at' }
  it { should respond_to 'updated_at' }

end
