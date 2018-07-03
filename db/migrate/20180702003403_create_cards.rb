class CreateCards < ActiveRecord::Migration[5.2]
  def change
    create_table :cards do |t|
      t.string :card_id, null: false
      t.string :token, limit: 32, null: true
      t.references :company

      t.timestamps
    end
  end
end
