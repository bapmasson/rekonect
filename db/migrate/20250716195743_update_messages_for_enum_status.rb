class UpdateMessagesForEnumStatus < ActiveRecord::Migration[7.1]
  def change
    remove_column :messages, :type, :string
    remove_column :messages, :draft, :boolean
    remove_column :messages, :received_message, :boolean
    add_column :messages, :status, :integer, default: 0, null: false
  end
end
