class Que7 < ActiveRecord::Migration[6.1]
  def up
    Que.migrate!(version: 7)
    Que::Scheduler::Migrations.migrate!(version: 7)
  end

  def down
    Que.migrate!(version: 6)
    Que::Scheduler::Migrations.migrate!(version: 6)
  end
end
