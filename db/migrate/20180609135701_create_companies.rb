class CreateCompanies < ActiveRecord::Migration[5.2]
  def change
    create_table :companies do |t|
      t.string :name, null: false, limit: 32
      t.string :zip, limit: 8
      t.string :tel, limit: 13
      t.string :address, limit: 64

      t.timestamps
    end
  end
end
