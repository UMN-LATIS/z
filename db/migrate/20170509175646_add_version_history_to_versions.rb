# rubocop:disable all

class AddVersionHistoryToVersions < ActiveRecord::Migration[5.0]
  def change
    add_column :versions, :version_history, :text
  end
end
