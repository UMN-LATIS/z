class TransferRequestUrl < ApplicationRecord
  belongs_to :transfer_request
  belongs_to :url
end
