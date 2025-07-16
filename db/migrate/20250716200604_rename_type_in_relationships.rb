class RenameTypeInRelationships < ActiveRecord::Migration[7.1]
  def change
    rename_column :relationships, :type, :relation_type
  end
end
