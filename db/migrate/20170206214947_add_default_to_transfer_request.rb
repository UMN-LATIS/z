# rubocop:disable all

class AddDefaultToTransferRequest < ActiveRecord::Migration[5.0]
  def change
    change_column :transfer_requests, :status, :string, default: 'pending'
  end
end
