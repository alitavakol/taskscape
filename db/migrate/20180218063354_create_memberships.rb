class CreateMemberships < ActiveRecord::Migration[5.1]
  def change
    create_table :memberships do |t|
      t.references :project, foreign_key: { to_table: :tasks }, null: false
      t.references :member, foreign_key: { to_table: :users }, null: false
      t.references :creator, foreign_key: { to_table: :users }

      t.timestamps
    end

    add_index :memberships, [:member_id, :project_id], unique: true
  end
end
