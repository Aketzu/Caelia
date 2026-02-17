class AddBitrateToSourcefiles < ActiveRecord::Migration[6.1]
  def change
    add_column :sourcefiles, :bitrate, :integer
  end
end
