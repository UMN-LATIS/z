class Url < ApplicationRecord
  belongs_to :group
  has_and_belongs_to_many :transfer_requests, join_table: TransferRequestUrl
  has_many :clicks

end
