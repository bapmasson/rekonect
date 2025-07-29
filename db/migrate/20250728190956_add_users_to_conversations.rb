class AddUsersToConversations < ActiveRecord::Migration[7.1]
  def change
    add_reference :conversations, :user1, foreign_key: { to_table: :users }
    add_reference :conversations, :user2, foreign_key: { to_table: :users }
  end
end
