class CreateAssignments < ActiveRecord::Migration[5.1]
  def change
    create_table :assignments do |t|
      t.references :task, foreign_key: true, null: false
      t.references :assignee, foreign_key: { to_table: :users }, null: false
      t.references :creator, foreign_key: { to_table: :users }

      t.timestamps
    end

    add_index :assignments, [:assignee_id, :task_id], unique: true
  end
end
