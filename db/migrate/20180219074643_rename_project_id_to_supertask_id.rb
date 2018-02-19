class RenameProjectIdToSupertaskId < ActiveRecord::Migration[5.1]
  def change
  	rename_column :tasks, :project_id, :supertask_id
  end
end
