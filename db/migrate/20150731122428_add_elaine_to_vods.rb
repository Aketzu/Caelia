class AddElaineToVods < ActiveRecord::Migration
  def change
    add_column :vods, :elaineid, :integer
  end
end
