class AddUrlNote < ActiveRecord::Migration[7.1]
  def change
    add_column :urls, :note, :text, null: true, default: nil
  end
end
