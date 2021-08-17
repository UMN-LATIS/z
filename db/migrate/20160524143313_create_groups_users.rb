# rubocop:disable all

class CreateGroupsUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :groups_users do |t|
      t.references :group, foreign_key: true
      t.references :user, foreign_key: true
      t.boolean    :notify_user_changes, default: false
    end
  end
end
