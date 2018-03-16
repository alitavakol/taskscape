class ChangeCreatorIdColumnNullable < ActiveRecord::Migration[5.1]
  def change
    change_column_null(:tasks, :creator_id, true)
  end
end
