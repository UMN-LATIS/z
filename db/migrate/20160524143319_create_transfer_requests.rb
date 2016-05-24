class CreateTransferRequests < ActiveRecord::Migration[5.0]
  def change
    create_table :transfer_requests do |t|
      t.integer :to_group_id
      t.integer :from_group_id
      t.string :key
      t.string :status

      t.timestamps
    end
  end
end
