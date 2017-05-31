class AddPeridToUmndidTable < ActiveRecord::Migration[5.0]
  def change
    create_table :perid_umndid do |t|
      t.string :perid
      t.string :umndid
    end
  end
end
