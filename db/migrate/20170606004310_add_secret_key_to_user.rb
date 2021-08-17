# rubocop:disable all

class AddSecretKeyToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :secret_key, :string
  end
end
