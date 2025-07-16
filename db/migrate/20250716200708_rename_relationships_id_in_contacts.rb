class RenameRelationshipsIdInContacts < ActiveRecord::Migration[7.1]
  def change
    rename_column :contacts, :relationships_id, :relationship_id
  end
end
