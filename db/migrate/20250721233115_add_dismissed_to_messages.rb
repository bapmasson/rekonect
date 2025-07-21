class AddDismissedToMessages < ActiveRecord::Migration[7.1]
  def change
    add_column :messages, :dismissed, :boolean
  end
end
