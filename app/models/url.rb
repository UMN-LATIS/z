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
  has_and_belongs_to_many  :transfer_requests, join_table: :transfer_request_urls
  
  # this next bit of magic removes any associations in the transfer_request_urls table
  before_destroy {|url| url.transfer_requests.clear}
  
  validates :keyword, uniqueness: true, presence: true
  validates :url, presence: true
  
  before_validation(on: :create) do
    self.group = User.first.context_group
    
    # Set clicks to zero
    self.total_clicks = 0
    
    # Set keyword if it's blank
    if self.keyword.blank?
      index = Url.maximum(:id).next
      until Url.where(keyword: index.to_s(36)).blank?
        index = index + 1
      end
      self.keyword = index.to_s(36)
    end
  end
  
  before_validation do 
    # Strip URL of any invalid characters, only allow alphanumeric
    self.keyword = self.keyword.gsub(/[^0-9a-z\\s]/i, '')
  end

end
