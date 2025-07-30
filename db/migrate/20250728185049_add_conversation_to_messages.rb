class AddConversationToMessages < ActiveRecord::Migration[7.1]
  def change
    add_reference :messages, :conversation, foreign_key: true
  end
end
