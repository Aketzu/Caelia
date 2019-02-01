class CreateRecordings < ActiveRecord::Migration[4.2]
  def change
    create_table :recordings do |t|
      t.string :basepath
      t.string :name

      t.timestamps null: false
    end
  end
end
