class ChangeXpLevelDefaultInUsers < ActiveRecord::Migration[7.1]

  # Migration qui change la valeur par défaut de xp_level dans la table users et qui la met à 0
  def change
    change_column_default :users, :xp_level, from: nil, to: 0
  end
end
