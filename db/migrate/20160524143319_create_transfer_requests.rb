class CreateTransferRequests < ActiveRecord::Migration[5.0]
  def change
    create_table :transfer_requests do |t|
      t.references :to_group, foreign_key: { to_table: :groups }
      t.references :from_group, foreign_key: { to_table: :groups }
      t.string :key
      t.string :status

      t.timestamps
    end
  end
end
