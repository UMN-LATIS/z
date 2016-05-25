# == Schema Information
#
# Table name: urls
#
#  id          :integer          not null, primary key
#  url         :string(255)
#  keyword     :string(255)
#  total_clicks      :integer
#  group_id    :integer
#  modified_by :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Url < ApplicationRecord
  belongs_to :group
  has_many :clicks
  has_and_belongs_to_many :transfer_requests, join_table: :transfer_request_urls
  
  # this next bit of magic removes any associations in the transfer_request_urls table
  before_destroy {|url| url.transfer_requests.clear}
  
  before_validation(on: :create) do
    self.group = User.first.context_group
    
    # Set clicks to zero
    self.total_clicks = 0
  end

end
