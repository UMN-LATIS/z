require "rails_helper"

RSpec.describe Url, :type => :model do
  # it "orders by last name" do
  #   lindeman = User.create!(first_name: "Andy", last_name: "Lindeman")
  #   chelimsky = User.create!(first_name: "David", last_name: "Chelimsky")
	# 
  #   expect(User.ordered_by_last_name).to eq([chelimsky, lindeman])
  # end
	
	
end

# == Schema Information
#
# Table name: collections
#
#  id          :integer          not null, primary key
#  name        :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  description :string
#

require 'rails_helper'

RSpec.describe Url, type: :model do
  before do
		@user = FactoryGirl.create(:user)
    @url = FactoryGirl.build(:url)
  end

  subject { @url }

  it {should be_valid}

end
