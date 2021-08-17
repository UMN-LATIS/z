# rubocop:disable all

class AddUidToPeridUmndid < ActiveRecord::Migration[5.0]
  def change
    add_column :perid_umndid, :uid, :string
  end
end
