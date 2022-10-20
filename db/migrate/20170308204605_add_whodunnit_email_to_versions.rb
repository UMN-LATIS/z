# rubocop:disable all

class AddWhodunnitEmailToVersions < ActiveRecord::Migration[5.0]
  def change
    add_column :versions, :whodunnit_email, :string
  end
end
