class CreateVods < ActiveRecord::Migration
  def change
    create_table :vods do |t|
      t.string :name
      t.references :recording, index: true
      t.decimal :start_pos, precision: 10, scale: 2
      t.decimal :end_pos, precision: 10, scale: 2

      t.timestamps null: false
    end
    add_foreign_key :vods, :recordings
  end
end
