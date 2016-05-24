class Url < ApplicationRecord
  belongs_to :group
  has_and_belongs_to_many :transfer_requests, join_table: TransferRequestUrl
  # this next bit of magic removes any associations in the transfer_request_urls table
  before_destroy {|url| url.transfer_requests.clear}
  has_many :transfer_requests, :dependent => :destroy
  has_many :clicks

end
