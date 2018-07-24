class AddLimitCardIdToCard < ActiveRecord::Migration[5.2]
  def change
    change_column :cards, :card_id, :string, limit: 64
  end
end
