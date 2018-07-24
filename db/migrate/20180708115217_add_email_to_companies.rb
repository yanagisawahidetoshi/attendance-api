class AddEmailToCompanies < ActiveRecord::Migration[5.2]
  def change
    add_column :companies, :email, :string, null: false, limit: 256, :unique => true
  end
end
