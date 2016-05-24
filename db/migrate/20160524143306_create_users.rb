class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.string :uid
      t.integer :context_group_id
      t.boolean :admin

      t.timestamps
    end
  end
end
