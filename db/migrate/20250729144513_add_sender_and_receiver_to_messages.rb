class AddSenderAndReceiverToMessages < ActiveRecord::Migration[7.1]
  def change
    add_column :messages, :sender_id, :bigint
    add_column :messages, :receiver_id, :bigint
  end
end
