class RemoveLastInteractionAtFromContacts < ActiveRecord::Migration[7.1]
  def change
    remove_column :contacts, :last_interaction_at, :date
  end
end
