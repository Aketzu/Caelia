class CreateRecordings < ActiveRecord::Migration
  def change
    create_table :recordings do |t|
      t.string :path
      t.string :filename
      t.integer :length

      t.timestamps null: false
    end
  end
end
