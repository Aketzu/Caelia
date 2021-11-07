# frozen_string_literal: true

class CreateQueSchdulerSchema < ActiveRecord::Migration[5.2]
  def change
    Que::Scheduler::Migrations.migrate!(version: 4)
  end
end
