class CardIdToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :card_id, :integer
    add_index :users, :card_id
  end
end
