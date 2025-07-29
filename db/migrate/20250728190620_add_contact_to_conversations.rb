class AddContactToConversations < ActiveRecord::Migration[7.1]
  def change
    add_reference :conversations, :contact, foreign_key: true
  end
end
