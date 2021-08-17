# rubocop:disable all

class SetTotalClicksDefaultInDb < ActiveRecord::Migration[5.0]
  def up
    change_column :urls, :total_clicks, :integer, default: 0
  end

  def down
    change_column :urls, :total_clicks, :integer, default: nil
  end
end
