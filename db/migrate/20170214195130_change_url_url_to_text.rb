# rubocop:disable all

class ChangeUrlUrlToText < ActiveRecord::Migration[5.0]
  def self.up
    change_column :urls, :url, :text
  end

  def self.down
    change_column :urls, :url, :string
  end
end
