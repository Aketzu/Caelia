class UpdateQueScheduler6 < ActiveRecord::Migration[5.2]
  def change
    Que::Scheduler::Migrations.migrate!(version: 6)
  end
end
