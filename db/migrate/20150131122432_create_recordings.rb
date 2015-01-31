class CreateRecordings < ActiveRecord::Migration
  def change
    create_table :recordings do |t|
      t.string :basepath
      t.string :name

      t.timestamps null: false
    end
  end
end
