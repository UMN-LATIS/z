# == Schema Information
#
# Table name: urls
#
#  id          :integer          not null, primary key
#  url         :string(255)
#  keyword     :string(255)
#  clicks      :integer
#  group_id    :integer
#  modified_by :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

require 'test_helper'

class UrlTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
