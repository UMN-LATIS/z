class AddIpLookupTable < ActiveRecord::Migration[5.0]
  def change
  	 create_table :ip2location_db1 do |t|
  	 	t.integer :ip_from, unsigned: true
  	 	t.integer :ip_to, unsigned: true
  	 	t.column(:country_code, 'char(2)')
  	 	t.string :country_name
  	 	t.index :ip_from
  	 	t.index :ip_to
  	 	t.index [:ip_from, :ip_to]
     end
  end
end
