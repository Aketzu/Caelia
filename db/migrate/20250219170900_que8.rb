class Que8 < ActiveRecord::Migration[6.1]
  def up
    Que::Scheduler::Migrations.migrate!(version: 8)
  end

  def down
    Que::Scheduler::Migrations.migrate!(version: 7)
  end
end
