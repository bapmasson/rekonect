class CreateContacts < ActiveRecord::Migration[7.1]
  def change
    create_table :contacts do |t|
      t.string :name
      t.date :last_interaction_at
      t.text :notes
      t.references :user, null: false, foreign_key: true
      t.references :relationships, null: false, foreign_key: true

      t.timestamps
    end
  end
end
