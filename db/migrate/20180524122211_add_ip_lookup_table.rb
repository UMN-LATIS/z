class AddIpLookupTable < ActiveRecord::Migration[5.0]
  def change
  	 create_table :ip2location_db1 do |t|
  	 	t.integer :ip_from
  	 	t.integer :ip_to
  	 	t.column(:country_code, 'char(2)')
  	 	t.string :country_name
  	 	add_index :ip2location_db1, :ip_from
  	 	add_index :ip2location_db1, :ip_to
  	 	add_index :ip2location_db1, [:ip_from, :ip_to]
  end
end
