class UpdateQueScheduler < ActiveRecord::Migration[8.1]
  def change
    Que::Scheduler::Migrations.migrate!(version: 8)
    Que::Scheduler::Migrations.reenqueue_scheduler_if_missing
  end
end
