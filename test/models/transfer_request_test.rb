# == Schema Information
#
# Table name: transfer_requests
#
#  id            :integer          not null, primary key
#  to_group_id   :integer
#  from_group_id :integer
#  key           :string(255)
#  status        :string(255)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

require 'test_helper'

class TransferRequestTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
