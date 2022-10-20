# rubocop:disable all

class AddWhodunnitNameToVersions < ActiveRecord::Migration[5.0]
  def change
    add_column :versions, :whodunnit_name, :string
  end
end
