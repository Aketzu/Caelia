class AddHiddenToRecording < ActiveRecord::Migration[5.2]
  def change
    add_column :recordings, :hidden, :boolean, default: false
  end
end
