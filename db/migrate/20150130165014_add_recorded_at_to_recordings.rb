class AddRecordedAtToRecordings < ActiveRecord::Migration
  def change
    add_column :recordings, :recorded_at, :datetime
  end
end
