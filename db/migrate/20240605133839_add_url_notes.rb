class AddUrlNotes < ActiveRecord::Migration[7.1]
  def change
    add_column :urls, :notes, :text
  end
end
