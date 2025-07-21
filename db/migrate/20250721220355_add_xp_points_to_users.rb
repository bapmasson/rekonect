class AddXpPointsToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :xp_points, :integer
  end
end
