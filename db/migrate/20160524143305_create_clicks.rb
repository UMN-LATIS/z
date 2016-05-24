class CreateClicks < ActiveRecord::Migration[5.0]
  def change
    create_table :clicks do |t|
      t.string :country_code
      t.references :url, foreign_key: true

      t.timestamps
    end
  end
end
