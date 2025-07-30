class AddContactUserIdToContacts < ActiveRecord::Migration[7.1]
  def change
    add_column :contacts, :contact_user_id, :bigint
    add_index :contacts, :contact_user_id
    add_foreign_key :contacts, :users, column: :contact_user_id
  end
end
