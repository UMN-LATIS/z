# rubocop:disable all

class AddFromGroupRequestorIdToTransferRequests < ActiveRecord::Migration[5.0]
  def change
    add_column :transfer_requests, :from_group_requestor_id, :integer, :after => :from_group_id
  end
end
