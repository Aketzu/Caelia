class CreateSourcefiles < ActiveRecord::Migration
  def change
    create_table :sourcefiles do |t|
      t.references :recording, index: true
      t.integer :nr
      t.string :filename
      t.decimal :length, precision: 10, scale: 2
      t.datetime :recorded_at

      t.timestamps null: false
    end
    add_foreign_key :sourcefiles, :recordings
  end
end
