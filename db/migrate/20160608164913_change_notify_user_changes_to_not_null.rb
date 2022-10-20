# rubocop:disable all

class ChangeNotifyUserChangesToNotNull < ActiveRecord::Migration[5.0]
  def change
    change_column :groups_users, :notify_user_changes, :boolean, :null => false
  end
end
