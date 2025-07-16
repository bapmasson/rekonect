class AddDetailsToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_column :users, :address, :text
    add_column :users, :username, :string
    add_column :users, :phone_number, :string
    add_column :users, :xp_level, :integer
    add_column :users, :birth_date, :date
  end
end
