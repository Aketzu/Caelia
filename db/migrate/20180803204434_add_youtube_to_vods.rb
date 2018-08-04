class AddYoutubeToVods < ActiveRecord::Migration[5.2]
  def change
    add_column :vods, :youtube, :string
  end
end
