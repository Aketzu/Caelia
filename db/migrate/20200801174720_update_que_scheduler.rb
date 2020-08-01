class UpdateQueScheduler < ActiveRecord::Migration[5.2]
  def change
    Que::Scheduler::Migrations.migrate!(version: 5)
  end
end
