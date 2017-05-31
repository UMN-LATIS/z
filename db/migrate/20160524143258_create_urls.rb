class CreateUrls < ActiveRecord::Migration[5.0]
  def change
    create_table :urls do |t|
      t.string :url
      t.string :keyword
      t.integer :total_clicks
      t.references :group, foreign_key: true
      t.integer :modified_by

      t.timestamps
    end
  end
end
