# rubocop:disable all

class AddRememberTokenToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :remember_token, :string
  end
end
