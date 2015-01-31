class AddStatusToVods < ActiveRecord::Migration
  def change
    add_column :vods, :encode_pos, :float
    add_column :vods, :status, :integer
  end
end
