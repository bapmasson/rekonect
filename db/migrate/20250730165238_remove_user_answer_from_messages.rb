class RemoveUserAnswerFromMessages < ActiveRecord::Migration[7.1]
  def change
    remove_column :messages, :user_answer, :text
  end
end
