class CreateSiteSettings < ActiveRecord::Migration[5.0]
  def change
    create_table :site_settings do |t|
      t.integer :next_id

      t.timestamps
    end
  end
end
