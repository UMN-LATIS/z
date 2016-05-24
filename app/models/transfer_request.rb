class TransferRequest < ApplicationRecord
  belongs_to :group, foreign_key: 'from_group_id'
  belongs_to :group, foreign_key: 'to_group_id'
  has_and_belongs_to_many :urls, join_table: TransferRequestUrl


end
