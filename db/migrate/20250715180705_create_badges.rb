class CreateBadges < ActiveRecord::Migration[7.1]
  def change
    create_table :badges do |t|
      t.string :title
      t.text :description
      t.text :condition_description

      t.timestamps
    end
  end
end
