class CreateMachines < ActiveRecord::Migration[5.2]
  def change
    create_table :machines do |t|
      t.string :name, limit: 32
      t.references :company, foreign_key: true
      t.string :mac_address, limit: 17, unique: true, null: false

      t.timestamps
    end
  end
end
