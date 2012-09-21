# This migration comes from summer_residents (originally 20120910030703)
class CreateSummerResidentsResidents < ActiveRecord::Migration
  def change
    create_table :summer_residents_residents do |t|
      t.integer :user_id
      t.string :first_name
      t.string :last_name
      t.integer :cell

      t.timestamps
    end
    add_index :summer_residents_residents, :user_id, :unique => true
  end
end
