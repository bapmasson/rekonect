class ChangeXpPointsDefaultOnUsers < ActiveRecord::Migration[7.1]
  def change
    change_column_default :users, :xp_points, 0
  end
end
