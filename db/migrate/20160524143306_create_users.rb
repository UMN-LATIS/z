# rubocop:disable all

class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.string :uid
      t.references :context_group, foreign_key: {to_table: :groups}
      t.references :default_group, foreign_key: {to_table: :groups}
      t.boolean :admin

      t.timestamps
    end
  end
end
