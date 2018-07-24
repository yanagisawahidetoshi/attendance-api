class CreateAttendances < ActiveRecord::Migration[5.2]
  def change
    create_table :attendances do |t|
      t.references :user, foreign_key: true
      t.date :date, null: false
      t.time :in_time
      t.time :out_time
      t.float :recess
      t.integer :rest
      t.float :operating_time
      t.timestamps
    end
  end
end
