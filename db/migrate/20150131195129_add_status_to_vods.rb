class AddStatusToVods < ActiveRecord::Migration[4.2]
  def change
    add_column :vods, :encode_pos, :float
    add_column :vods, :status, :integer
  end
end
