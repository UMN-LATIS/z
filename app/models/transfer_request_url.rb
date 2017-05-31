# == Schema Information
#
# Table name: transfer_request_urls
#
#  transfer_request_id :integer
#  url_id              :integer
#

class TransferRequestUrl < ApplicationRecord
  belongs_to :transfer_request
  belongs_to :url
end
