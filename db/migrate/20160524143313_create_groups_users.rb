class CreateGroupsUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :groups_users, id: false do |t|
      t.references :group, foreign_key: true
      t.references :user, foreign_key: true
    end
  end
end
