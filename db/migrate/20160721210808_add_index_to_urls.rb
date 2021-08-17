# rubocop:disable all

class AddIndexToUrls < ActiveRecord::Migration[5.0]
  def change
    add_index :urls, :keyword, unique: true
  end
end
