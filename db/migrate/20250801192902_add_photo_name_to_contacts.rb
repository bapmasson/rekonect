class AddPhotoNameToContacts < ActiveRecord::Migration[7.1]
  def change
    add_column :contacts, :photo_name, :string
  end
end
