class CreateTasks < ActiveRecord::Migration[5.1]
  def change
    create_table :tasks do |t|
      t.string :title, null: false
      t.text :description
      t.integer :visibility, null: false
      t.integer :status
      t.integer :urgency
      t.integer :importance
      t.integer :effort
      t.datetime :due_date
      t.references :project, foreign_key: { to_table: :tasks } # references the supertask (project)
      t.references :creator, foreign_key: { to_table: :users }, null: false # references user who created this task
      t.integer :x
      t.integer :y
      t.string :color
      t.boolean :archived, null: false

      t.timestamps
    end
  end
end
