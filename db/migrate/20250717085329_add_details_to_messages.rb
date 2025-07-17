class AddDetailsToMessages < ActiveRecord::Migration[7.1]
  def change
    add_column :messages, :ai_draft, :text
    add_column :messages, :user_answer, :text
    add_column :messages, :status, :integer, default: 0
    remove_column :messages, :type, :string
    remove_column :messages, :draft, :boolean
    remove_column :messages, :received_message, :boolean
  end
end
