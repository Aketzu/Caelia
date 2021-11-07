# frozen_string_literal: true

class AddElaineToVods < ActiveRecord::Migration[4.2]
  def change
    add_column :vods, :elaineid, :integer
  end
end
