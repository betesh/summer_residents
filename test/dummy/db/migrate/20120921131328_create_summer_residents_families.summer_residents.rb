# This migration comes from summer_residents (originally 20120910030842)
class CreateSummerResidentsFamilies < ActiveRecord::Migration
  def change
    create_table :summer_residents_families do |t|
      t.integer :home_id
      t.integer :bungalow_id
      t.integer :father_id
      t.integer :mother_id

      t.timestamps
    end
    add_index :summer_residents_families, :home_id, :unique => true
    add_index :summer_residents_families, :bungalow_id, :unique => true
    add_index :summer_residents_families, :father_id, :unique => true
    add_index :summer_residents_families, :mother_id, :unique => true
  end
end
