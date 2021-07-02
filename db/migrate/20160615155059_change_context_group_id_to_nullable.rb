class ChangeContextGroupIdToNullable < ActiveRecord::Migration[5.0]
  def change
    change_column :users, :context_group_id, :integer, :null => true
  end
end
