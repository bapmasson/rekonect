class CreateRelationships < ActiveRecord::Migration[7.1]
  def change
    create_table :relationships do |t|
      t.string :type
      t.integer :proximity

      t.timestamps
    end
  end
end
